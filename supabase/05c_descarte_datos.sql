-- ============================================================
-- CRITERIO 2: DATOS INSUFICIENTES
-- Ejecutar DESPUÉS del Criterio 1 (si aplica)
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados
SELECT
  'Leads a archivar por datos insuficientes' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (
    company_vertical IS NULL OR company_vertical IN ('Unknown', '')
    OR country IS NULL OR country = ''
    OR (company_employees IS NULL AND company_revenue IS NULL)
  );

-- DESPUÉS: Ejecutar el UPDATE (quitar comentario cuando estés listo)
-- UPDATE public.builtwith_company_targets
-- SET
--   enrichment_tier = 'archived',
--   discard_reason = 'insufficient_data',
--   discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND (
--     company_vertical IS NULL OR company_vertical IN ('Unknown', '')
--     OR country IS NULL OR country = ''
--     OR (company_employees IS NULL AND company_revenue IS NULL)
--   );
