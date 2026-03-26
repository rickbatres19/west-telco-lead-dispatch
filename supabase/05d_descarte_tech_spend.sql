-- ============================================================
-- CRITERIO 3: TECH SPEND NULO + EMPRESAS PEQUEÑAS
-- Ejecutar DESPUÉS de los criterios anteriores
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados
-- Nota: company_tech_spend es texto, no número
SELECT
  'Leads a archivar por tech spend nulo + pequeños' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (
    company_tech_spend IS NULL
    OR company_tech_spend = ''
    OR company_tech_spend = '0'
    OR company_tech_spend = '$0'
    OR company_tech_spend = 'Unknown'
  )
  AND (company_employees IS NOT NULL AND company_employees < 100);

-- Ver ejemplos de valores actuales en company_tech_spend
-- SELECT DISTINCT company_tech_spend, COUNT(*) as total
-- FROM public.builtwith_company_targets
-- WHERE company_tech_spend IS NOT NULL
-- GROUP BY company_tech_spend
-- ORDER BY total DESC
-- LIMIT 20;

-- DESPUÉS: Ejecutar el UPDATE (quitar comentario cuando estés listo)
-- UPDATE public.builtwith_company_targets
-- SET
--   enrichment_tier = 'archived',
--   discard_reason = 'no_tech_spend_small',
--   discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND (
--     company_tech_spend IS NULL
--     OR company_tech_spend = ''
--     OR company_tech_spend = '0'
--     OR company_tech_spend = '$0'
--     OR company_tech_spend = 'Unknown'
--   )
--   AND (company_employees IS NOT NULL AND company_employees < 100);
