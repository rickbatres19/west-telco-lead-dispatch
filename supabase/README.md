# Supabase — West Telco Lead Dispatch

## Proyecto

- **Nombre:** West Telco Leads
- **Project ID:** `mjrsvivaowhnkfumsahc`
- **URL:** `https://mjrsvivaowhnkfumsahc.supabase.co`
- **Región:** us-east-1
- **Plan:** Free

## Migraciones

| Archivo | Descripción | Fecha |
|---|---|---|
| `01_initial_schema.sql` | Schema inicial: builtwith_files, builtwith_raw_rows, builtwith_company_targets, scoring_config, agent_runs, agent_actions, agent_incidents, agent_policy_rules, outreach_queue, search_runs, sources_log, integration_state, companies, leads | Feb 2026 |
| `02_partner_reports.sql` | Tablas de reportes: partners, partner_reports, partner_report_leads | 18 Mar 2026 |
| `03_partner_assignment.sql` | Columnas de asignación en builtwith_company_targets: assigned_to_partner, assigned_at, assigned_report_id | 18 Mar 2026 |

## Tablas principales

### builtwith_company_targets
Tabla central. 28,367 filas. Empresas detectadas con BuiltWith que son candidatas a productos West Telco.

Columnas clave:
- `canonical_domain` — dominio principal de la empresa
- `west_telco_product` — producto recomendado (Zoom/Xcally/EDB/Dropbox)
- `offer_family` — familia del producto
- `offering_rationale` — razón por la que es un buen lead
- `priority_score` — score 0-100 calculado por múltiples dimensiones
- `enrichment_status` — pending | ready | partial
- `first_contact_name` / `first_contact_email` — contacto encontrado por Hunter
- `assigned_to_partner` — nombre del partner asignado (null = disponible)
- `assigned_at` — timestamp de cuándo fue asignado
- `assigned_report_id` — UUID del reporte que realizó la asignación

### partner_reports
Registro de cada reporte mensual generado desde el dashboard.

### partner_report_leads
Leads incluidos en cada reporte (relación report → leads).

### agent_runs
Log de cada ejecución del pipeline de enriquecimiento n8n.

## Datos actuales (18 Mar 2026)

```sql
SELECT enrichment_status, COUNT(*) FROM builtwith_company_targets GROUP BY enrichment_status;
-- ready:   9,564
-- pending: 18,558
-- partial: 245
```

## Conexión desde n8n

Usar nodo **Supabase nativo** (no Postgres directo):
- Host: `https://mjrsvivaowhnkfumsahc.supabase.co`  
- Service Role Secret: Supabase → Settings → API → service_role

⚠️ La conexión directa Postgres falla por IPv6 (ENETUNREACH). Siempre usar el nodo Supabase nativo.
