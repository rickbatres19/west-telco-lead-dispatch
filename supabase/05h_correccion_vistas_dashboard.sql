-- ============================================================
-- CORRECCIÓN DE VISTAS PARA DASHBOARD
-- Fecha: 26 Mar 2026
-- Propósito: Alinear vistas con los 3 indicadores del dashboard
-- ============================================================
--
-- INDICADORES ESPERADOS:
--   TOTAL REGISTROS: 13,592 (suma de los otros dos)
--   ENRIQUECIDOS (READY): 273 → Pestaña 2 "Leads Calificados"
--   EN ENRIQUECIMIENTO: 13,319 → Pestaña 1 "Universo de Leads"
-- ============================================================

-- ============================================================
-- 1. VISTA UNIVERSO DE LEADS (Pestaña 1)
-- Solo los que están PENDIENTES de enriquecer (no ready/partial)
-- ============================================================

DROP VIEW IF EXISTS public.v_universo_pendientes;

CREATE OR REPLACE VIEW public.v_universo_pendientes AS
SELECT *
FROM public.builtwith_company_targets
WHERE enrichment_status = 'pending'
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND discarded_at IS NULL;

-- ============================================================
-- 2. VISTA LEADS CALIFICADOS (Pestaña 2)
-- Solo los que YA tienen contacto enriquecido (status = ready)
-- Usa los datos directamente de builtwith_company_targets
-- ============================================================

DROP VIEW IF EXISTS public.v_report_leads CASCADE;
DROP VIEW IF EXISTS public.v_report_leads_filtered CASCADE;

CREATE OR REPLACE VIEW public.v_report_leads AS
SELECT
    t.*,
    t.first_contact_name as contact_name,
    t.first_contact_email as contact_email,
    t.first_contact_phone as contact_phone,
    t.contact_position as job_title,
    t.contact_department as department,
    NULL::text as seniority,
    NULL::numeric as email_confidence,
    NULL::text as linkedin_url
FROM public.builtwith_company_targets t
WHERE t.enrichment_status = 'ready'
  AND t.first_contact_email IS NOT NULL
  AND COALESCE(t.enrichment_tier, 'high') != 'archived'
  AND t.discarded_at IS NULL;

-- Vista con filtro adicional para el dashboard (misma estructura)
CREATE OR REPLACE VIEW public.v_report_leads_filtered AS
SELECT * FROM public.v_report_leads;

-- ============================================================
-- 3. FUNCIÓN DE ESTADÍSTICAS ACTUALIZADA
-- ============================================================

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
  -- Total activo = pendientes + enriquecidos (ready)
  SELECT COUNT(*) INTO total_count
  FROM public.builtwith_company_targets
  WHERE (enrichment_status = 'pending' OR enrichment_status = 'ready')
    AND COALESCE(enrichment_tier, 'high') != 'archived'
    AND discarded_at IS NULL;

  -- Solo pendientes (en enriquecimiento)
  SELECT COUNT(*) INTO pending_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'pending'
    AND COALESCE(enrichment_tier, 'high') != 'archived'
    AND discarded_at IS NULL;

  -- Solo ready (enriquecidos)
  SELECT COUNT(*) INTO ready_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'ready'
    AND COALESCE(enrichment_tier, 'high') != 'archived'
    AND discarded_at IS NULL;

  -- Parciales (se cuentan aparte, no suman al total principal)
  SELECT COUNT(*) INTO partial_count
  FROM public.builtwith_company_targets
  WHERE enrichment_status = 'partial'
    AND COALESCE(enrichment_tier, 'high') != 'archived'
    AND discarded_at IS NULL;

  -- Asignados
  SELECT COUNT(*) INTO assigned_count
  FROM public.builtwith_company_targets
  WHERE assigned_to_partner IS NOT NULL
    AND COALESCE(enrichment_tier, 'high') != 'archived'
    AND discarded_at IS NULL;

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

-- ============================================================
-- 4. FUNCIÓN GET_REPORT_LEADS_COUNT ACTUALIZADA
-- ============================================================

CREATE OR REPLACE FUNCTION public.get_report_leads_count()
RETURNS int AS $$
DECLARE
  count_result int;
BEGIN
  SELECT COUNT(DISTINCT t.id) INTO count_result
  FROM public.builtwith_company_targets t
  WHERE t.enrichment_status = 'ready'
    AND t.first_contact_email IS NOT NULL
    AND COALESCE(t.enrichment_tier, 'high') != 'archived'
    AND t.discarded_at IS NULL;

  RETURN count_result;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- 5. VERIFICACIÓN DE CONTEOS
-- ============================================================

SELECT '=== VERIFICACIÓN DE CONTEOS ===' as chequeo;

SELECT
  'TOTAL REGISTROS (pending + ready)' as indicador,
  COUNT(*) as valor
FROM public.builtwith_company_targets
WHERE (enrichment_status = 'pending' OR enrichment_status = 'ready')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND discarded_at IS NULL

UNION ALL

SELECT
  'EN ENRIQUECIMIENTO (Pestaña 1 - pending)' as indicador,
  COUNT(*) as valor
FROM public.v_universo_pendientes

UNION ALL

SELECT
  'ENRIQUECIDOS READY (Pestaña 2 - con email)' as indicador,
  COUNT(*) as valor
FROM public.v_report_leads

UNION ALL

SELECT
  'Archivados (referencia)' as indicador,
  COUNT(*) as valor
FROM public.builtwith_company_targets
WHERE enrichment_tier = 'archived';

-- Verificar que la suma cuadre
SELECT
  'SUMA VERIFICACIÓN' as chequeo,
  (SELECT COUNT(*) FROM public.v_universo_pendientes) +
  (SELECT COUNT(*) FROM public.v_report_leads) as suma_total,
  (SELECT COUNT(*) FROM public.builtwith_company_targets
   WHERE (enrichment_status = 'pending' OR enrichment_status = 'ready')
     AND COALESCE(enrichment_tier, 'high') != 'archived'
     AND discarded_at IS NULL) as total_esperado;
