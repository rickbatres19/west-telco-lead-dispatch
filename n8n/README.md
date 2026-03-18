# n8n — West Telco Lead Dispatch

## Workflows

| Archivo | Descripción | Estado |
|---|---|---|
| `01_enrichment_pipeline_hunter.json` | Pipeline nocturno de enriquecimiento con Hunter.io | ✅ Activo |

## Credenciales requeridas en n8n

### Supabase account (nodo nativo Supabase)
- **Host:** `https://mjrsvivaowhnkfumsahc.supabase.co`
- **Service Role Secret:** ver Supabase → Settings → API → service_role key

### Hunter.io API
- Configurada como HTTP Header Auth o directamente en URL del nodo HTTP Request
- API key en: https://hunter.io/api-keys

### WestTelco SMTP (para email de resumen nocturno)
- Configurar con cuenta de email corporativo

## Workflow 01 — Enrichment Pipeline

**Trigger:** Schedule, 2am diario (America/Mexico_City)
**Batch:** 100 leads por ejecución
**Lógica:**
1. Obtiene 100 leads con `enrichment_status = pending` ordenados por `priority_score DESC`
2. Para cada lead consulta Hunter.io con el `canonical_domain`
3. Si Hunter encuentra emails: selecciona el contacto con rol más relevante (IT/Director/Manager), marca `ready`
4. Si Hunter no encuentra: marca `partial`, `next_enrichment_step = manual_linkedin`
5. Actualiza `builtwith_company_targets` vía nodo Supabase nativo
6. Loguea el run en `agent_runs` con métricas de procesamiento
7. Si hubo nuevos `ready`: envía email de resumen nocturno

**Métricas del primer run (18 Mar 2026):**
- 100 procesados / 33 ready / 67 partial
- Hit rate Hunter: 33%
- Costo estimado: $0.20 USD

## Notas de configuración

- Usar nodo **Supabase nativo** (no Postgres) para evitar error ENETUNREACH por IPv6
- El servidor n8n no tiene IPv6 habilitado; la conexión directa a Supabase falla
- La solución es usar el nodo Supabase que opera por HTTPS/REST
