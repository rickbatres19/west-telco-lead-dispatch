# CONTEXT — West Telco Lead Dispatch

## Qué es este proyecto

Sistema interno de West Telco para habilitar las ventas de sus partners/resellers en México y LATAM. West Telco es un mayorista boutique de tecnología (Zoom, Xcally, EDB, Dropbox, SolarWinds) que distribuye a través de canal.

El problema que resuelve: los equipos de ventas de los partners no saben a quién venderle. Este sistema les entrega mensualmente un lote de leads calificados, listos para contactar, en un Excel con nombre de empresa, país, producto recomendado, score y contacto con email.

## Modelo operativo

1. West Telco es el único operador — controla qué leads van a qué partner
2. Los partners NO tienen acceso al sistema — solo reciben el Excel mensual
3. El enriquecimiento es automático (n8n + Hunter.io, corre 2am diario)
4. La asignación es manual — desde el dashboard interno se seleccionan leads y se asignan a un partner específico
5. Un lead asignado queda bloqueado y no puede darse a otro partner

## Tablas principales en Supabase

| Tabla | Descripción |
|---|---|
| `builtwith_company_targets` | 28k+ empresas detectadas con BuiltWith, enriquecidas con Hunter |
| `partner_reports` | Registro de cada reporte mensual generado |
| `partner_report_leads` | Leads específicos incluidos en cada reporte |
| `partners` | Catálogo de partners |
| `agent_runs` | Log de cada ejecución del pipeline de enriquecimiento |
| `scoring_config` | Configuración del scoring de leads |

## Campos clave en builtwith_company_targets

- `enrichment_status`: `pending` | `ready` | `partial`
- `assigned_to_partner`: nombre del partner asignado (null = disponible)
- `assigned_at`: timestamp de asignación
- `assigned_report_id`: UUID del reporte que lo asignó
- `priority_score`: score calculado 0-100
- `west_telco_product`: producto West Telco recomendado
- `first_contact_email` / `first_contact_name`: contacto encontrado por Hunter

## Usuarios del sistema

- **Rick Batres** — Gerente de IT, West Telco (operador principal)

## Decisiones técnicas tomadas

- Se descartó modelo multiusuario/portal para partners — demasiado complejo para arrancar
- Se eligió entrega por Excel mensual en lugar de API o portal
- n8n usa nodo Supabase nativo (no Postgres) para evitar problema de IPv6 en conexión directa
- Pipeline procesa 100 leads/noche ordenados por priority_score DESC
- Hunter.io como única fuente de enriquecimiento (Apollo.io como posible segunda fuente futura)
