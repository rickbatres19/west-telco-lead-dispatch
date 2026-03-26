-- ============================================================
-- CRITERIO 4: GEO SECUNDARIO + BAJO SCORE
-- Ecuador y Perú con score bajo
-- Ejecutar DESPUÉS de los criterios anteriores
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

-- Ver distribución por país para confirmar
-- SELECT
--   country,
--   COUNT(*) as total,
--   COUNT(*) FILTER (WHERE priority_score < 40 OR priority_score IS NULL) as bajo_score
-- FROM public.builtwith_company_targets
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
-- GROUP BY country
-- ORDER BY total DESC;

-- DESPUÉS: Ejecutar el UPDATE (quitar comentario cuando estés listo)
-- UPDATE public.builtwith_company_targets
-- SET
--   enrichment_tier = 'archived',
--   discard_reason = 'geo_secondary_low_score',
--   discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND country IN ('EC', 'PE')
--   AND (priority_score IS NULL OR priority_score < 40);
