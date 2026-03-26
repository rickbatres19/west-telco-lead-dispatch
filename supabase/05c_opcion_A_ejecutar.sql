-- ============================================================
-- CRITERIO 2 OPCION A: DATOS INSUFICIENTES (sin país Y sin vertical)
-- Copiar y pegar TODO este bloque en Supabase SQL Editor
-- ============================================================

UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'insufficient_data',
  discarded_at = NOW()
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') = 'high'
  AND (country IS NULL OR country = '')
  AND (company_vertical IS NULL OR company_vertical IN ('Unknown', ''));

-- Verificar cuántos se archivaron
SELECT
  'Total archivados por insufficient_data' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE discard_reason = 'insufficient_data';
