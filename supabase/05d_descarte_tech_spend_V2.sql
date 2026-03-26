-- ============================================================
-- CRITERIO 3 CORREGIDO V2: TECH SPEND NULO + EMPRESAS PEQUEÑAS
-- Maneja formato de empleados con comas (ej: "94,000")
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados
-- Usamos una subconsulta para limpiar primero
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
  AND (
    company_employees IS NOT NULL
    AND company_employees != ''
    AND company_employees != 'Unknown'
    AND (
      -- Extraer solo números y quitar comas, luego convertir
      REPLACE(REGEXP_REPLACE(company_employees, '[^0-9]', '', 'g'), ',', '')::INTEGER < 100
    )
  );

-- Ver ejemplos de valores para debug
-- SELECT company_employees,
--        REPLACE(REGEXP_REPLACE(company_employees, '[^0-9]', '', 'g'), ',', '')::INTEGER as num
-- FROM public.builtwith_company_targets
-- WHERE company_employees IS NOT NULL
--   AND company_employees != ''
--   AND company_employees != 'Unknown'
-- LIMIT 10;

-- EJECUTAR EL UPDATE:
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
--   AND (
--     company_employees IS NOT NULL
--     AND company_employees != ''
--     AND company_employees != 'Unknown'
--     AND REPLACE(REGEXP_REPLACE(company_employees, '[^0-9]', '', 'g'), ',', '')::INTEGER < 100
--   );
