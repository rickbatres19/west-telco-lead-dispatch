-- ============================================================
-- CRITERIO 4: GEO SECUNDARIO + BAJO SCORE
-- Ecuador (EC) y Perú (PE) con score bajo (< 40)
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados
SELECT
  'Leads a archivar por GEO secundario + bajo score' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND country IN ('EC', 'PE')
  AND (priority_score IS NULL OR priority_score < 40);

-- Ver distribución por país
-- SELECT
--   country,
--   COUNT(*) as total,
--   COUNT(*) FILTER (WHERE priority_score IS NULL OR priority_score < 40) as bajo_score
-- FROM public.builtwith_company_targets
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND country IN ('EC', 'PE')
-- GROUP BY country;

-- EJECUTAR EL UPDATE:
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'geo_secondary_low_score',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND country IN ('EC', 'PE')
  AND (priority_score IS NULL OR priority_score < 40);

-- Verificar cuántos se archivaron
SELECT
  'Total archivados por geo_secondary_low_score' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE discard_reason = 'geo_secondary_low_score';
