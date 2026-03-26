-- ============================================================
-- PASO FINAL: Actualizar vistas y funciones
-- Ejecutar DESPUÉS de aplicar todos los criterios de descarte
-- ============================================================

-- ============================================================
-- VISTAS ACTUALIZADAS
-- ============================================================

-- Recrear vista v_universo_pendientes excluyendo archivados
DROP VIEW IF EXISTS public.v_universo_pendientes;

CREATE OR REPLACE VIEW public.v_universo_pendientes AS
SELECT *
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND discarded_at IS NULL;

-- Crear vista filtrada para leads calificados (con contactos)
DROP VIEW IF EXISTS public.v_report_leads_filtered;

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
  AND c.id IS NOT NULL;

-- ============================================================
-- FUNCIÓN DE ESTADÍSTICAS ACTUALIZADA
-- ============================================================

-- Reemplazar función get_lead_stats para filtrar archivados
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

-- Verificar que las vistas y funciones se crearon correctamente
SELECT 'Vistas creadas:' as info;
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name IN ('v_universo_pendientes', 'v_report_leads_filtered');

SELECT 'Funciones creadas:' as info;
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('get_lead_stats', 'get_report_leads_count');
