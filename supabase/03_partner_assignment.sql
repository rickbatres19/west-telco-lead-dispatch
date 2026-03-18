-- Migration 03: Partner Assignment Tracking
-- Fecha: 18 Mar 2026
-- Descripción: Agrega columnas de asignación a builtwith_company_targets
-- para evitar que el mismo lead sea dado a dos partners distintos

ALTER TABLE public.builtwith_company_targets
  ADD COLUMN IF NOT EXISTS assigned_to_partner text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS assigned_at timestamptz DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS assigned_report_id uuid DEFAULT NULL;

CREATE INDEX IF NOT EXISTS idx_targets_assigned_partner 
  ON public.builtwith_company_targets(assigned_to_partner);

CREATE INDEX IF NOT EXISTS idx_targets_assigned_at 
  ON public.builtwith_company_targets(assigned_at);

-- Vista útil para ver disponibilidad de leads por producto
CREATE OR REPLACE VIEW public.leads_availability AS
SELECT
  west_telco_product,
  territory,
  country,
  COUNT(*) FILTER (WHERE enrichment_status = 'ready' AND assigned_to_partner IS NULL) AS disponibles,
  COUNT(*) FILTER (WHERE enrichment_status = 'ready' AND assigned_to_partner IS NOT NULL) AS asignados,
  COUNT(*) FILTER (WHERE enrichment_status = 'pending') AS pendientes,
  COUNT(*) FILTER (WHERE enrichment_status = 'ready') AS total_ready
FROM builtwith_company_targets
GROUP BY west_telco_product, territory, country
ORDER BY disponibles DESC;
