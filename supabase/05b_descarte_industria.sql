-- ============================================================
-- CRITERIO 1: INDUSTRIA NO TARGET
-- Ejecutar DESPUÉS de 05a_add_columns.sql
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados (sin hacer cambios)
SELECT
  'Leads a archivar por industria no target' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND company_vertical IN (
    'Agriculture',           -- Agricultura primaria
    'Fishing',               -- Pesca
    'Forestry',              -- Silvicultura
    'Mining',                -- Minería artesanal
    'Individual',            -- Personas individuales
    'Small Business',        -- Negocios muy pequeños
    'Government',            -- Gobierno
    'Education'              -- Educación
  );

-- DESPUÉS: Ejecutar el UPDATE (quitar comentario de -- cuando estés listo)
-- UPDATE public.builtwith_company_targets
-- SET
--   enrichment_tier = 'archived',
--   discard_reason = 'non_target_industry',
--   discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND company_vertical IN (
--     'Agriculture',
--     'Fishing',
--     'Forestry',
--     'Mining',
--     'Individual',
--     'Small Business',
--     'Government',
--     'Education'
--   );

-- Ver qué industrias tienes actualmente (para decidir cuáles descartar)
-- SELECT company_vertical, COUNT(*) as total
-- FROM public.builtwith_company_targets
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
-- GROUP BY company_vertical
-- ORDER BY total DESC;
