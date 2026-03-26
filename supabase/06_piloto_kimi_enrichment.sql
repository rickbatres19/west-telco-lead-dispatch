-- ============================================================
-- PILOTO: Enriquecimiento con Kimi AI (antes de Apollo)
-- Propósito: Probar hit rate de búsqueda manual asistida vs Apollo
-- ============================================================

-- Paso 1: Seleccionar lote representativo de 100 leads para prueba
-- Criterios: Prioridad alta, no archivados, sin contactos previos

-- Ver distribución por país y producto (para muestreo estratificado)
SELECT
    country,
    west_telco_product,
    COUNT(*) as disponibles,
    AVG(priority_score) as avg_score
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND NOT EXISTS (
    SELECT 1 FROM public.target_contacts tc
    WHERE tc.canonical_domain = builtwith_company_targets.canonical_domain
  )
GROUP BY country, west_telco_product
ORDER BY disponibles DESC;

-- Paso 2: Crear tabla de seguimiento para el piloto
CREATE TABLE IF NOT EXISTS public.kimi_enrichment_piloto (
    id SERIAL PRIMARY KEY,
    target_id BIGINT REFERENCES public.builtwith_company_targets(id),
    company_name TEXT,
    canonical_domain TEXT,
    country TEXT,
    west_telco_product TEXT,
    priority_score INTEGER,
    -- Resultados Kimi
    kimia_full_name TEXT,
    kimia_job_title TEXT,
    kimia_email TEXT,
    kimia_phone TEXT,
    kimia_linkedin_url TEXT,
    kimia_seniority TEXT,
    kimia_confidence INTEGER, -- 0-100 estimación de certeza
    kimia_source TEXT, -- linkedin, web, crunchbase, etc.
    kimia_notes TEXT,
    -- Metadata
    enriched_at TIMESTAMPTZ DEFAULT NOW(),
    enriched_by TEXT DEFAULT 'kimi_ai',
    -- Validación
    validated BOOLEAN DEFAULT FALSE,
    validation_notes TEXT
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_piloto_target_id ON public.kimi_enrichment_piloto(target_id);
CREATE INDEX IF NOT EXISTS idx_piloto_country ON public.kimi_enrichment_piloto(country);
CREATE INDEX IF NOT EXISTS idx_piloto_confidence ON public.kimi_enrichment_piloto(kimia_confidence);

-- Paso 3: Seleccionar lote de 100 leads representativos
-- Distribución: 40 MX, 20 BR, 15 AR, 10 CL, 10 CO, 5 OTROS
-- Prioridad score > 30, ordenados aleatoriamente

INSERT INTO public.kimi_enrichment_piloto (
    target_id, company_name, canonical_domain, country,
    west_telco_product, priority_score
)
SELECT
    id, company_name, canonical_domain, country,
    west_telco_product, priority_score
FROM (
    -- México (40 leads)
    SELECT id, company_name, canonical_domain, country,
           west_telco_product, priority_score,
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
    FROM public.builtwith_company_targets
    WHERE enrichment_status IN ('pending', 'ready', 'partial')
      AND COALESCE(enrichment_tier, 'high') != 'archived'
      AND country = 'MX'
      AND priority_score >= 30
      AND NOT EXISTS (
        SELECT 1 FROM public.target_contacts tc
        WHERE tc.canonical_domain = builtwith_company_targets.canonical_domain
      )
    LIMIT 40
) mx

UNION ALL

SELECT target_id, company_name, canonical_domain, country,
       west_telco_product, priority_score, rn
FROM (
    -- Brasil (20 leads)
    SELECT id as target_id, company_name, canonical_domain, country,
           west_telco_product, priority_score,
           ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
    FROM public.builtwith_company_targets
    WHERE enrichment_status IN ('pending', 'ready', 'partial')
      AND COALESCE(enrichment_tier, 'high') != 'archived'
      AND country = 'BR'
      AND priority_score >= 30
      AND NOT EXISTS (
        SELECT 1 FROM public.target_contacts tc
        WHERE tc.canonical_domain = builtwith_company_targets.canonical_domain
      )
    LIMIT 20
) br

UNION ALL

-- Agregar AR (15), CL (10), CO (10), otros (5) de forma similar
-- (Simplificado para el ejemplo)
SELECT id, company_name, canonical_domain, country,
       west_telco_product, priority_score,
       ROW_NUMBER() OVER (ORDER BY RANDOM()) as rn
FROM public.builtwith_company_targets
WHERE enrichment_status IN ('pending', 'ready', 'partial')
  AND COALESCE(enrichment_tier, 'high') != 'archived'
  AND country IN ('AR', 'CL', 'CO', 'PE', 'EC', 'UY')
  AND priority_score >= 30
  AND NOT EXISTS (
    SELECT 1 FROM public.target_contacts tc
    WHERE tc.canonical_domain = builtwith_company_targets.canonical_domain
  )
LIMIT 15

ON CONFLICT DO NOTHING;

-- Verificar selección
SELECT
    country,
    COUNT(*) as total,
    AVG(priority_score) as avg_score
FROM public.kimi_enrichment_piloto
GROUP BY country
ORDER BY total DESC;

-- ============================================================
-- METRICAS DE ÉXITO DEL PILOTO
-- ============================================================

-- Query para medir resultados después del enriquecimiento
-- Hit rate = contactos encontrados / total del lote

-- SELECT
--     COUNT(*) as total_piloto,
--     COUNT(*) FILTER (WHERE kimia_full_name IS NOT NULL) as con_nombre,
--     COUNT(*) FILTER (WHERE kimia_email IS NOT NULL) as con_email,
--     COUNT(*) FILTER (WHERE kimia_phone IS NOT NULL) as con_telefono,
--     COUNT(*) FILTER (WHERE kimia_linkedin_url IS NOT NULL) as con_linkedin,
--     ROUND(COUNT(*) FILTER (WHERE kimia_email IS NOT NULL) * 100.0 / COUNT(*), 1) as hit_rate_email,
--     ROUND(AVG(kimia_confidence) FILTER (WHERE kimia_confidence IS NOT NULL), 1) as avg_confidence
-- FROM public.kimi_enrichment_piloto;

-- ============================================================
-- COMPARACIÓN CON APOLLO (después de ambos)
-- ============================================================

-- Tabla para comparar Apollo vs Kimi
CREATE TABLE IF NOT EXISTS public.enrichment_comparativa (
    id SERIAL PRIMARY KEY,
    target_id BIGINT,
    company_name TEXT,
    canonical_domain TEXT,
    -- Kimi results
    kimia_found BOOLEAN DEFAULT FALSE,
    kimia_email TEXT,
    kimia_confidence INTEGER,
    -- Apollo results
    apollo_found BOOLEAN DEFAULT FALSE,
    apollo_email TEXT,
    apollo_confidence TEXT, -- 'verified', 'pattern', etc.
    -- Winner
    mejor_fuente TEXT, -- 'kimi', 'apollo', 'empate', 'ninguno'
    notas TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
