-- ============================================================
-- PASO 1: Agregar columnas de descarte
-- Ejecutar primero ANTES de cualquier criterio de descarte
-- ============================================================

-- Agregar columnas de descarte a builtwith_company_targets
ALTER TABLE public.builtwith_company_targets
  ADD COLUMN IF NOT EXISTS enrichment_tier text DEFAULT 'high',
  ADD COLUMN IF NOT EXISTS discard_reason text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS discarded_at timestamptz DEFAULT NULL;

-- Crear índices para filtrado eficiente
CREATE INDEX IF NOT EXISTS idx_targets_enrichment_tier
  ON public.builtwith_company_targets(enrichment_tier);

CREATE INDEX IF NOT EXISTS idx_targets_discarded
  ON public.builtwith_company_targets(discarded_at)
  WHERE discarded_at IS NOT NULL;

-- Verificar que las columnas se crearon correctamente
SELECT
  column_name,
  data_type,
  column_default
FROM information_schema.columns
WHERE table_name = 'builtwith_company_targets'
  AND column_name IN ('enrichment_tier', 'discard_reason', 'discarded_at')
ORDER BY column_name;
