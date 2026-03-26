-- ============================================================
-- ANÁLISIS DE DESCARTE DE LEADS
-- Propósito: Identificar cuántos leads cumplen cada criterio de descarte
-- Fecha: 2026-03-26
-- ============================================================

-- Criterio 1: INDUSTRIA NO TARGET
-- Analizar qué verticales tenemos y cuáles son potencialmente no-target
SELECT
    company_vertical,
    COUNT(*) as total,
    ROUND(AVG(priority_score), 1) as avg_score
FROM builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
GROUP BY company_vertical
ORDER BY total DESC;

-- Criterio 2: DATOS INSUFICIENTES
-- Leads con faltantes críticos
SELECT
    'Datos insuficientes' as criterio,
    COUNT(*) as total
FROM builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND (
    company_vertical IS NULL OR company_vertical = 'Unknown' OR company_vertical = ''
    OR country IS NULL OR country = ''
    OR (company_employees IS NULL AND company_revenue IS NULL)
  );

-- Criterio 3: TECH SPEND NULO + PEQUEÑOS
SELECT
    'Tech spend nulo + pequeños' as criterio,
    COUNT(*) as total
FROM builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND (company_tech_spend IS NULL OR company_tech_spend = 0)
  AND (company_employees IS NOT NULL AND company_employees < 100);

-- Criterio 4: GEO SECUNDARIO + BAJO SCORE
-- Ecuador y Perú con score < 40
SELECT
    'GEO secundario + bajo score' as criterio,
    COUNT(*) as total
FROM builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND country IN ('EC', 'PE')
  AND (priority_score IS NULL OR priority_score < 40);

-- Criterio 5: SEÑALES TECH NEGATIVAS
-- Empresas con tecnologías legacy o competidores arraigados
-- (esto requiere análisis del campo trigger_technology)
SELECT
    trigger_technology,
    COUNT(*) as total
FROM builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND trigger_technology IS NOT NULL
GROUP BY trigger_technology
ORDER BY total DESC
LIMIT 30;

-- ============================================================
-- ANÁLISIS DE DUPLICADOS
-- ============================================================

-- Verificar si hay dominios duplicados
SELECT
    canonical_domain,
    COUNT(*) as dup_count
FROM builtwith_company_targets
GROUP BY canonical_domain
HAVING COUNT(*) > 1
ORDER BY dup_count DESC
LIMIT 20;

-- ============================================================
-- RESUMEN ACTUAL
-- ============================================================

SELECT
    enrichment_status,
    COUNT(*) as total
FROM builtwith_company_targets
GROUP BY enrichment_status
ORDER BY total DESC;
