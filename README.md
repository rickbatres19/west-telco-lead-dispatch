# West Telco · Lead Dispatch

Sistema interno de habilitación de ventas para partners de West Telco.

## Objetivo

Generar y distribuir automáticamente bases de datos de leads calificados a los partners/resellers de West Telco, eliminando la fricción de prospección y permitiendo que los equipos de ventas de los partners se enfoquen en cerrar, no en buscar.

## Stack

| Capa | Herramienta |
|---|---|
| Base de datos | Supabase (PostgreSQL) |
| Automatizaciones | n8n (self-hosted) |
| Frontend / Dashboard | HTML + Vercel |
| Enriquecimiento | Hunter.io |
| Fuente de datos | BuiltWith exports |

## Módulos

1. **Lead Dispatch Dashboard** — interfaz interna para seleccionar, asignar y exportar leads a partners
2. **Enrichment Pipeline** — workflow n8n que procesa 100 leads/noche y obtiene emails con Hunter.io
3. **Partner Reports** — sistema de reportes mensuales en Excel con tracking de asignaciones

## Estructura

```
west-telco-lead-dispatch/
├── app/                        # Dashboard web (Vercel)
│   └── leads-dashboard-v2.html
├── n8n/
│   ├── README.md
│   └── workflows/
│       └── 01_enrichment_pipeline_hunter.json
├── supabase/
│   ├── README.md
│   └── 01_initial_schema.sql
│   └── 02_partner_reports.sql
│   └── 03_partner_assignment.sql
├── docs/
│   ├── arquitectura.md
│   └── flujo_operativo.md
├── scripts/
│   └── prepare_builtwith_import.md
├── CONTEXT.md
└── README.md
```

## Proyecto Supabase

- **Project:** West Telco Leads
- **Project ID:** `mjrsvivaowhnkfumsahc`
- **URL:** `https://mjrsvivaowhnkfumsahc.supabase.co`
- **Region:** us-east-1

## Métricas iniciales (Mar 2026)

- 28,367 empresas target en `builtwith_company_targets`
- 9,564 leads `ready` con email verificado
- 18,558 leads `pending` en pipeline de enriquecimiento
- 33% hit rate con Hunter.io en primer run
- Cobertura: MX, BR, AR, CL, CO, PE, EC
