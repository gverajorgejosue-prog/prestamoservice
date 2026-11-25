# PrestaControl - prestamoservice

API REST stateless con Spring Boot 3, JWT y PostgreSQL para la gestión de cartera de préstamos.

## Requisitos
- Java 17+
- Maven 3.9+
- PostgreSQL 14+

## Variables de entorno
- `DB_URL` (default: `jdbc:postgresql://localhost:5432/prestacontrol_db`)
- `DB_USERNAME` (default: `postgres`)
- `DB_PASSWORD` (default: `postgres`)
- `JWT_SECRET` (Base64, mínimo 256 bits)
- `JWT_EXPIRATION` (default: `86400000`)
- `PORT` (default: `8080`)

## Ejecutar localmente
1. Crear base de datos:
   ```sql
   CREATE DATABASE prestacontrol_db;
   ```
2. Ejecutar:
   ```bash
   mvn spring-boot:run
   ```

## Docker / Render
- Dockerfile multi-stage listo para Render Web Service.
- Render inyecta `PORT`; el contenedor lo respeta con `-Dserver.port=${PORT}`.

## Endpoints
- `POST /auth/register`
- `POST /auth/login`
- `GET /prestamos`
- `GET /prestamos/{id}`
- `POST /prestamos`
- `PUT /prestamos/{id}`
- `DELETE /prestamos/{id}`
- `GET /prestamos/resumen`
