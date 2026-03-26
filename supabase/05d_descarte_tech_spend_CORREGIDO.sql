-- ============================================================
-- CRITERIO 3 CORREGIDO: TECH SPEND NULO + EMPRESAS PEQUEÑAS
-- Nota: company_employees y company_tech_spend son TEXT
-- ============================================================

-- PRIMERO: Ver cuántos leads se verán afectados
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
    AND CAST(NULLIF(REGEXP_REPLACE(company_employees, '[^0-9]', '', 'g'), '') AS INTEGER) < 100
  );

-- EJECUTAR EL UPDATE (copiar y pegar TODO este bloque):
UPDATE public.builtwith_company_targets
SET
  enrichment_tier = 'archived',
  discard_reason = 'no_tech_spend_small',
  discarded_at = NOW()
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
    AND CAST(NULLIF(REGEXP_REPLACE(company_employees, '[^0-9]', '', 'g'), '') AS INTEGER) < 100
  );

-- Verificar cuántos se archivaron
SELECT
  'Total archivados por no_tech_spend_small' as descripcion,
  COUNT(*) as total
FROM public.builtwith_company_targets
WHERE discard_reason = 'no_tech_spend_small';
