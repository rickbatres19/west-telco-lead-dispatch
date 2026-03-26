-- ============================================================
-- CRITERIO 2 AJUSTADO: DATOS INSUFICIENTES (VERSIÓN PERMISIVA)
-- Solo descartar si faltan datos CRÍTICOS (no con Unknown)
-- ============================================================

-- Opción A: Solo descartar si NO tiene país Y NO tiene vertical definida
-- (muy restrictivo - solo los que realmente no sabemos nada)
SELECT
  'Leads sin país ni vertical definida (estricto)' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (
    country IS NULL OR country = ''
  )
  AND (
    company_vertical IS NULL OR company_vertical IN ('Unknown', '')
  );

-- Opción B: Descartar si faltan TODOS los datos demográficos
-- (país + vertical + tamaño + ingresos - todo vacío)
SELECT
  'Leads sin datos demográficos (país + vertical + empleados + ingresos)' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (
    country IS NULL OR country = ''
  )
  AND (
    company_vertical IS NULL OR company_vertical IN ('Unknown', '')
  )
  AND company_employees IS NULL
  AND company_revenue IS NULL;

-- Opción C: Descartar si no tienen país (lo más crítico)
SELECT
  'Leads sin país definido (solo)' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (country IS NULL OR country = '');

-- ============================================================
-- ELIGE UNA OPCIÓN Y EJECUTA EL UPDATE CORRESPONDIENTE
-- ============================================================

-- UPDATE Opción A (recomendado - balanceado):
-- UPDATE public.builtwith_company_targets
-- SET enrichment_tier = 'archived', discard_reason = 'insufficient_data', discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND (country IS NULL OR country = '')
--   AND (company_vertical IS NULL OR company_vertical IN ('Unknown', ''));

-- UPDATE Opción B (muy estricto - solo los peores):
-- UPDATE public.builtwith_company_targets
-- SET enrichment_tier = 'archived', discard_reason = 'insufficient_data', discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND (country IS NULL OR country = '')
--   AND (company_vertical IS NULL OR company_vertical IN ('Unknown', ''))
--   AND company_employees IS NULL
--   AND company_revenue IS NULL;

-- UPDATE Opción C (solo país - muy permisivo):
-- UPDATE public.builtwith_company_targets
-- SET enrichment_tier = 'archived', discard_reason = 'insufficient_data', discarded_at = NOW()
-- WHERE enrichment_status IN ('pending', 'ready', 'partial')
--   AND COALESCE(enrichment_tier, 'high') = 'high'
--   AND (country IS NULL OR country = '');
