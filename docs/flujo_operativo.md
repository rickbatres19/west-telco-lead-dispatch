# Flujo Operativo — West Telco Lead Dispatch

## Ciclo mensual de despacho de leads

### Paso 1 — Verificar disponibilidad
Abre el dashboard → Pestaña **"Todos los leads"**
- Revisa el contador "Disponibles" en el sidebar
- Filtra por producto o territorio si necesitas ver disponibilidad específica
- Leads con badge naranja = ya asignados a otro partner

### Paso 2 — Configurar el reporte
Pestaña **"Generar reporte"** → sección "Configurar reporte":
- **Nombre del partner** — nombre exacto del partner (se usará para rastrear asignaciones)
- **Email del partner** — para referencia interna
- **Periodo** — ej. "Abril 2025"
- **Notas internas** — opcional, para contexto interno

### Paso 3 — Seleccionar leads
- Usa los filtros: producto, territorio, score
- Los leads ya asignados aparecen bloqueados automáticamente (no se pueden seleccionar)
- Selecciona individualmente o usa "Seleccionar todos en vista"
- El contador muestra cuántos llevas seleccionados

### Paso 4 — Generar y asignar
- Clic en **"Generar y asignar"**
- Confirma en el modal (muestra resumen antes de ejecutar)
- El sistema automáticamente:
  - Crea el registro en `partner_reports`
  - Guarda los leads en `partner_report_leads`
  - Marca cada lead con `assigned_to_partner = nombre_partner`
  - Descarga el Excel listo para enviar

### Paso 5 — Enviar al partner
- El Excel se descarga automáticamente
- Envíalo por email al partner con contexto de cómo usar los leads

---

## Monitoreo del pipeline de enriquecimiento

El pipeline corre automáticamente a las 2am. Para revisar:

1. En n8n → Workflow **"WestTelco · Enrichment Pipeline"** → pestaña **Executions**
2. En Supabase → tabla `agent_runs` → última fila = último run

**Query de monitoreo:**
```sql
SELECT 
  started_at,
  processed_count,
  success_count,
  blocked_count,
  error_count,
  estimated_cost_usd,
  status
FROM agent_runs
ORDER BY started_at DESC
LIMIT 10;
```

**Ver disponibilidad actual:**
```sql
SELECT * FROM leads_availability ORDER BY disponibles DESC LIMIT 20;
```

---

## Gestión de leads parciales

Los leads en estado `partial` tienen empresa y dominio pero Hunter no encontró email.
Opciones para recuperarlos:

1. **LinkedIn manual** — buscar contacto directamente, agregar email en Supabase
2. **Aumentar batch de Hunter** — algunos dominios requieren más intentos
3. **Apollo.io como segunda fuente** — integración futura planificada

Para actualizar un lead parcial manualmente:
```sql
UPDATE builtwith_company_targets SET
  first_contact_name = 'Nombre Apellido',
  first_contact_email = 'email@empresa.com',
  has_contact_email = true,
  enrichment_status = 'ready',
  verification_source = 'manual_linkedin'
WHERE canonical_domain = 'dominio.com';
```
