-- ============================================================
-- DIAGNÓSTICO DE CONTEOS REALES
-- ============================================================

-- 1. Conteo total por enrichment_status (sin filtros)
SELECT 'TOTAL POR ESTADO' as seccion;
SELECT enrichment_status, COUNT(*) as cantidad
FROM public.builtwith_company_targets
GROUP BY enrichment_status
ORDER BY cantidad DESC;

-- 2. Conteo con filtros de archivados
SELECT 'CON FILTRO ARCHIVADOS' as seccion;
SELECT
  enrichment_status,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE COALESCE(enrichment_tier, 'high') != 'archived') as no_archivados,
  COUNT(*) FILTER (WHERE discarded_at IS NULL) as no_discarded,
  COUNT(*) FILTER (WHERE COALESCE(enrichment_tier, 'high') != 'archived' AND discarded_at IS NULL) as activos
FROM public.builtwith_company_targets
GROUP BY enrichment_status
ORDER BY total DESC;

-- 3. Verificar leads con contactos en target_contacts
SELECT 'LEADS CON CONTACTOS (JOIN)' as seccion;
SELECT
  t.enrichment_status,
  COUNT(DISTINCT t.id) as leads_con_contacto
FROM public.builtwith_company_targets t
INNER JOIN public.target_contacts c ON t.canonical_domain = c.canonical_domain
GROUP BY t.enrichment_status;

-- 4. Verificar la vista v_report_leads actual
SELECT 'VISTA v_report_leads' as seccion;
SELECT COUNT(*) as cantidad FROM public.v_report_leads;

-- 5. Verificar la vista v_universo_pendientes actual
SELECT 'VISTA v_universo_pendientes' as seccion;
SELECT COUNT(*) as cantidad FROM public.v_universo_pendientes;

-- 6. Conteo de archivados
SELECT 'ARCHIVADOS' as seccion;
SELECT
  COUNT(*) FILTER (WHERE enrichment_tier = 'archived') as archivados_tier,
  COUNT(*) FILTER (WHERE discarded_at IS NOT NULL) as discarded,
  COUNT(*) as total_general
FROM public.builtwith_company_targets;

-- 7. Desglose por producto y territorio
SELECT 'DESGLOSE POR PRODUCTO' as seccion;
SELECT
  west_telco_product,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE enrichment_status = 'pending') as pending,
  COUNT(*) FILTER (WHERE enrichment_status = 'ready') as ready,
  COUNT(*) FILTER (WHERE enrichment_status = 'partial') as partial,
  COUNT(*) FILTER (WHERE enrichment_tier = 'archived') as archivados
FROM public.builtwith_company_targets
GROUP BY west_telco_product
ORDER BY total DESC;
