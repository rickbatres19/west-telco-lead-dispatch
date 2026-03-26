-- ============================================================
-- VERIFICACIÓN: Contar leads archivados vs activos
-- Ejecutar después de aplicar los criterios deseados
-- ============================================================

-- Total de leads archivados por razón
SELECT
  discard_reason,
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) as porcentaje
FROM public.builtwith_company_targets
WHERE enrichment_tier = 'archived'
GROUP BY discard_reason
ORDER BY total DESC;

-- Resumen: Activos vs Archivados
SELECT
  'Leads ACTIVOS (no archivados)' as estado,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'

UNION ALL

SELECT
  'Leads ARCHIVADOS' as estado,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_tier = 'archived'

UNION ALL

SELECT
  'TOTAL GENERAL' as estado,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial');

-- Distribución de leads activos por estado
SELECT
  enrichment_status,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
GROUP BY enrichment_status
ORDER BY total DESC;
