# Scripts — West Telco Lead Dispatch

## prepare_builtwith_import

Proceso para importar nuevos exports de BuiltWith a Supabase.

### Cuándo ejecutar
- Cuando BuiltWith genera un nuevo export de tecnologías competidoras o afines
- Para refrescar la base con datos más recientes (recomendado: cada 3-6 meses)

### Pasos

1. **Descargar export de BuiltWith**
   - Ir a https://builtwith.com/lists
   - Exportar CSV con los filtros: tecnología target + región LATAM
   - Guardar en `/csv/`

2. **Registrar el archivo en builtwith_files**
```sql
INSERT INTO builtwith_files (file_name, snapshot_date, priority, west_telco_product, technology, geo_scope)
VALUES ('nombre_archivo.csv', 'YYYY-MM-DD', 'P1', 'Zoom', 'ZoomPhone', 'LATAM');
```

3. **Importar rows crudos**
   - Usar el editor de Supabase o un script Python para hacer bulk insert a `builtwith_raw_rows`
   - Asegurarse de incluir `source_file_name` = nombre del archivo registrado

4. **Procesar a company_targets**
   - El pipeline de n8n detecta nuevos dominios en `builtwith_raw_rows`
   - O ejecutar manualmente la query de inserción a `builtwith_company_targets`

### Deduplicación
La tabla `builtwith_company_targets` tiene `canonical_domain` como clave de deduplicación.
Si el dominio ya existe, actualizar campos en lugar de insertar:
```sql
INSERT INTO builtwith_company_targets (canonical_domain, ...)
ON CONFLICT (canonical_domain) DO UPDATE SET
  snapshot_date = EXCLUDED.snapshot_date,
  updated_at = now();
```

## Notas
- Los CSVs de BuiltWith tienen formato inconsistente entre exports — revisar columnas antes de importar
- El campo `technology_spend_raw` viene como string con formato "$X,XXX" — convertir a numeric
- El campo `employees_raw` puede venir como "1,000-5,000" — tomar el promedio o el mínimo
