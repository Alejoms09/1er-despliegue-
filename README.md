# API Reactiva + Railway

API CRUD reactiva hecha con Spring WebFlux + R2DBC + PostgreSQL.

## Endpoints

- `GET /` estado de la API
- `GET /api/tasks` listar tareas
- `GET /api/tasks/{id}` buscar por id
- `POST /api/tasks` crear tarea
- `PUT /api/tasks/{id}` actualizar tarea
- `DELETE /api/tasks/{id}` eliminar tarea

## JSON de ejemplo

```json
{
  "title": "Terminar despliegue",
  "completed": false
}
```

## Variables de entorno (Railway)

La app toma estas variables. Railway las crea automaticamente al agregar PostgreSQL al proyecto.

- `PGHOST`
- `PGPORT`
- `PGDATABASE`
- `PGUSER`
- `PGPASSWORD`
- `PORT` (la inyecta Railway)

## Ejecutar en local

1. Levanta PostgreSQL local y exporta variables `PG*`.
2. Ejecuta:

```bash
./mvnw spring-boot:run
```

## Despliegue

El repositorio incluye `Dockerfile`, por lo que Railway construye y publica automaticamente desde GitHub.
