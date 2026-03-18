# Arquitectura — West Telco Lead Dispatch

## Diagrama general

```
BuiltWith (exports CSV)
        │
        ▼
builtwith_raw_rows (Supabase)
        │
        ▼
builtwith_company_targets ◄──── scoring_config
        │                              │
        │                    priority_score calculado
        │
        ▼
Pipeline n8n (2am diario)
        │
        ├── Hunter.io domain search
        │       ├── Encontró → enrichment_status = ready
        │       └── No encontró → enrichment_status = partial
        │
        └── Log en agent_runs
        
        
Lead Dispatch Dashboard (Vercel)
        │
        ├── Pestaña 1: Todos los leads
        │       └── Vista completa con estado de asignación
        │
        ├── Pestaña 2: Generar reporte
        │       ├── Selección manual de leads disponibles
        │       ├── Leads asignados bloqueados (no seleccionables)
        │       ├── Genera partner_report + partner_report_leads
        │       ├── Marca leads como assigned_to_partner
        │       └── Exporta Excel para enviar al partner
        │
        └── Pestaña 3: Histórico
                └── Lista de reportes con drill-down de leads
```

## Decisiones de arquitectura

### ¿Por qué no un portal multiusuario para partners?
Se evaluó pero se descartó para el MVP. Agrega complejidad de autenticación, gestión de accesos y UX que no aporta valor en esta etapa. Los partners reciben el Excel y ya — menos fricción, más velocidad.

### ¿Por qué Hunter.io y no Apollo.io?
West Telco ya tenía cuenta activa de Hunter.io. Apollo.io queda como fuente secundaria futura para aumentar el hit rate en dominios LATAM donde Hunter tiene menos cobertura.

### ¿Por qué 100 leads/noche y no más?
Balance entre costo de API y velocidad de enriquecimiento. A 100/noche los 18,558 pendientes quedan listos en ~6 meses. Se puede aumentar el batch si se requiere más velocidad.

### ¿Por qué nodo Supabase nativo en n8n y no Postgres directo?
El servidor n8n (self-hosted) no tiene IPv6 habilitado. Supabase resuelve `db.*.supabase.co` a IPv6, causando ENETUNREACH. El nodo Supabase nativo usa la API REST por HTTPS (puerto 443) evitando el problema completamente.

## Flujo de datos completo

```
1. Importación inicial
   CSV BuiltWith → builtwith_raw_rows → builtwith_company_targets
   (procesado con scripts/prepare_builtwith_import.md)

2. Enriquecimiento continuo (automático, nocturno)
   builtwith_company_targets [pending]
   → Hunter.io API
   → builtwith_company_targets [ready/partial]
   → agent_runs [log]

3. Despacho de leads (manual, mensual)
   Lead Dispatch Dashboard
   → Selección manual de leads ready + disponibles
   → partner_reports + partner_report_leads
   → builtwith_company_targets.assigned_to_partner = nombre_partner
   → Excel descargado para envío al partner
```

## Tablas y sus responsabilidades

| Tabla | Responsabilidad | Escritura |
|---|---|---|
| `builtwith_raw_rows` | Datos crudos importados de BuiltWith | Import script |
| `builtwith_company_targets` | Empresas procesadas, enriquecidas y scoreadas | n8n pipeline + Dashboard |
| `scoring_config` | Reglas de scoring configurables | Manual |
| `agent_runs` | Log de ejecuciones del pipeline | n8n |
| `partner_reports` | Registro de reportes generados | Dashboard |
| `partner_report_leads` | Detalle de leads por reporte | Dashboard |
| `partners` | Catálogo de partners | Manual |
