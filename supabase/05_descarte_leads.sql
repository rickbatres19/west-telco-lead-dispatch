-- ============================================================
-- MIGRACIÓN 05: Sistema de Descarte de Leads
-- Fecha: 2026-03-26
-- Descripción: Agrega campos para marcar leads descartados y crea vista filtrada
-- ============================================================

-- Paso 1: Agregar columnas de descarte a builtwith_company_targets
ALTER TABLE public.builtwith_company_targets
  ADD COLUMN IF NOT EXISTS enrichment_tier text DEFAULT 'high',
  ADD COLUMN IF NOT EXISTS discard_reason text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS discarded_at timestamptz DEFAULT NULL;

-- Crear índices para filtrado eficiente
CREATE INDEX IF NOT EXISTS idx_targets_enrichment_tier
  ON public.builtwith_company_targets(enrichment_tier);

CREATE INDEX IF NOT EXISTS idx_targets_discarded
  ON public.builtwith_company_targets(discarded_at)
  WHERE discarded_at IS NOT NULL;

-- ============================================================
-- CRITERIOS DE DESCARTE
-- Ejecutar estos UPDATEs uno por uno para revisar impacto
-- ============================================================

-- Criterio 1: INDUSTRIA NO TARGET
-- Lista de verticales a descartar (ajustar según análisis)
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'non_target_industry',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier = 'high'  -- Solo si no está ya marcado
  AND company_vertical IN (
    'Agriculture',           -- Agricultura primaria
    'Fishing',               -- Pesca
    'Forestry',              -- Silvicultura
    'Mining',                -- Minería artesanal
    'Individual',            -- Personas individuales
    'Small Business',        -- Negocios muy pequeños
    'Government',            -- Gobierno (solo si es municipal pequeño - ajustar)
    'Education'              -- Educación K-12 (ajustar si es institución grande)
  );

-- Criterio 2: DATOS INSUFICIENTES
-- Faltan campos críticos: industria, país, y (tamaño O ingresos)
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'insufficient_data',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier = 'high'
  AND (
    company_vertical IS NULL OR company_vertical IN ('Unknown', '')
    OR country IS NULL OR country = ''
    OR (company_employees IS NULL AND company_revenue IS NULL)
  );

-- Criterio 3: TECH SPEND NULO + PEQUEÑOS
-- Nota: company_tech_spend es texto, verificamos si está vacío o es '$0' o '0'
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'no_tech_spend_small',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier = 'high'
  AND (
    company_tech_spend IS NULL
    OR company_tech_spend = ''
    OR company_tech_spend = '0'
    OR company_tech_spend = '$0'
    OR company_tech_spend = 'Unknown'
  )
  AND (company_employees IS NOT NULL AND company_employees < 100);

-- Criterio 4: GEO SECUNDARIO + BAJO SCORE
-- Ecuador y Perú con score bajo
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'geo_secondary_low_score',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier = 'high'
  AND country IN ('EC', 'PE')
  AND (priority_score IS NULL OR priority_score < 40);

-- Criterio 5: SEÑALES TECH NEGATIVAS
-- Esto requiere análisis manual del campo trigger_technology
-- Comentado hasta revisar qué tecnologías son negativas
/*
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'negative_tech_signals',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier = 'high'
  AND trigger_technology IN (
    -- Lista de tecnologías a descartar
    'Competitor_A',
    'Legacy_Only'
  );
*/

-- ============================================================
-- VISTAS ACTUALIZADAS
-- ============================================================

-- Recrear vista v_universo_pendientes excluyendo archivados
DROP VIEW IF EXISTS public.v_universo_pendientes;

-- Crear nueva versión filtrada
CREATE OR REPLACE VIEW public.v_universo_pendientes AS
SELECT *
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND discarded_at IS NULL;

-- También actualizar v_report_leads para excluir archivados
-- (Nota: Guardar definición actual antes si existe)
DROP VIEW IF EXISTS public.v_report_leads_filtered;

-- Crear vista filtrada para leads calificados (contactos)
CREATE OR REPLACE VIEW public.v_report_leads_filtered AS
SELECT
    t.*,
    c.full_name as contact_name,
    c.email as contact_email,
    c.phone as contact_phone,
    c.job_title,
    c.seniority,
    c.department,
    c.email_confidence,
    c.linkedin_url
FROM public.builtwith_company_targets t
LEFT JOIN public.target_contacts c ON t.canonical_domain = c.canonical_domain
WHERE t.enrichment_status IN ('ready', 'partial')
  AND COALESCE(t.enrichment_tier, 'high') != 'archived'
  AND t.discarded_at IS NULL
  AND c.id IS NOT NULL;  -- Solo leads con contactos enriquecidos

-- ============================================================
-- FUNCIÓN DE ESTADÍSTICAS ACTUALIZADA
-- ============================================================

-- Reemplazar función existente get_lead_stats para filtrar archivados
CREATE OR REPLACE FUNCTION public.get_lead_stats()
RETURNS json AS $$
DECLARE
  result json;
  total_count int;
  pending_count int;
  ready_count int;
  partial_count int;
  assigned_count int;
  archived_count int;
BEGIN
  -- Total de leads activos (no archivados)
  SELECT COUNT(*) INTO total_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status IN ('pending', 'ready', 'partial')
    AND COALESCE(enrichment_tier, 'high') != 'archived';

  -- Por estado
  SELECT COUNT(*) INTO pending_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'pending'
    AND COALESCE(enrichment_tier, 'high') != 'archived';

  SELECT COUNT(*) INTO ready_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'ready'
    AND COALESCE(enrichment_tier, 'high') != 'archived';

  SELECT COUNT(*) INTO partial_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'partial'
    AND COALESCE(enrichment_tier, 'high') != 'archived';

  -- Asignados
  SELECT COUNT(*) INTO assigned_count
  FROM public.builtwith_company_targets
  WHERE assigned_to_partner IS NOT NULL
    AND COALESCE(enrichment_tier, 'high') != 'archived';

  -- Archivados (para referencia)
  SELECT COUNT(*) INTO archived_count
  FROM public.builtwith_company_targets
  WHERE enrichment_tier = 'archived';

  result := json_build_object(
    'total', total_count,
    'pending', pending_count,
    'ready', ready_count,
    'partial', partial_count,
    'assigned', assigned_count,
    'archived', archived_count
  );

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Reemplazar función get_report_leads_count
CREATE OR REPLACE FUNCTION public.get_report_leads_count()
RETURNS int AS $$
DECLARE
  count_result int;
BEGIN
  SELECT COUNT(DISTINCT t.id) INTO count_result
  FROM public.builtwith_company_targets t
  INNER JOIN public.target_contacts c ON t.canonical_domain = c.canonical_domain
  WHERE t.enrichment_status IN ('ready', 'partial')
    AND COALESCE(t.enrichment_tier, 'high') != 'archived'
    AND t.discarded_at IS NULL;

  RETURN count_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Verificar cuántos quedan activos
SELECT
  'Total activos' as metric,
  COUNT(*) as value
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND enrichment_tier != 'archived'

UNION ALL

SELECT
  'Archivados' as metric,
  COUNT(*) as value
FROM public.builtwith_company_targets
WHERE enrichment_tier = 'archived';

-- Ver distribución por razón de descarte
SELECT
  discard_reason,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_tier = 'archived'
GROUP BY discard_reason
ORDER BY total DESC;
