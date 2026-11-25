# PrestaControl

Sistema de gestión de cartera de préstamos compuesto por:

| Carpeta | Descripción |
|---|---|
| `prestamoservice/` | API REST Spring Boot 3 + JWT + PostgreSQL |
| `prestacontrol_app/` | App móvil Flutter (Material 3) |

---

## 1. Backend — `prestamoservice`

### Requisitos
- JDK 17 o superior (probado con JDK 21 / 25)
- Maven 3.9+ (o el wrapper `mvnw` incluido)
- PostgreSQL 14+

### Variables de entorno
| Variable | Default |
|---|---|
| `DB_URL` | `jdbc:postgresql://localhost:5432/prestacontrol_db` |
| `DB_USERNAME` | `postgres` |
| `DB_PASSWORD` | `postgres` |
| `JWT_SECRET` | clave Base64 de ejemplo (cámbiala en producción) |
| `JWT_EXPIRATION` | `86400000` (24 h) |
| `PORT` | `8080` |

### Ejecutar en IntelliJ IDEA
1. **File > Open** → `prestamoservice/pom.xml` → *Open as Project*.
2. **File > Project Structure > Project SDK** → JDK 17+.
3. Edita la Run Configuration de `PrestamoserviceApplication` y añade las variables de entorno.
4. Run ▶.

O por terminal:
```bash
cd prestamoservice
./mvnw spring-boot:run        # Windows: mvnw.cmd spring-boot:run
```

### Endpoints
| Método | Ruta | Auth |
|---|---|---|
| POST | `/auth/register` | No |
| POST | `/auth/login` | No |
| GET | `/prestamos` | Sí |
| GET | `/prestamos/{id}` | Sí |
| POST | `/prestamos` | Sí |
| PUT | `/prestamos/{id}` | Sí |
| DELETE | `/prestamos/{id}` | Sí |
| GET | `/prestamos/resumen` | Sí |

### Despliegue en Render
- **Root Directory:** `prestamoservice`
- **Environment:** Docker
- **Variables:** las de la tabla anterior (Render inyecta `PORT`).

### Postman
Importar `prestamoservice/postman/PrestaControl.postman_collection.json`.

---

## 2. App — `prestacontrol_app`

### Requisitos
- Flutter **3.50+** (stable, Dart 3.14+)
- Android SDK 36+
- JDK 21 (JBR de Android Studio) para Gradle 9.5

### Configurar URL de la API
`lib/config/api_config.dart`:
```dart
static const String baseUrl = 'https://prestamoservice-csjv.onrender.com';
```
Para emulador local usa `http://10.0.2.2:8080`.

### Ejecutar en Android Studio
1. Instala los plugins **Flutter** y **Dart**.
2. **File > Open** → carpeta `prestacontrol_app`.
3. `flutter pub get`.
4. Selecciona el emulador **Medium Phone** y pulsa Run ▶.

### Ejecutar por terminal
```bash
cd prestacontrol_app
flutter pub get
flutter run
```

### Funcionalidades
- Splash con sesión persistente (`flutter_secure_storage` + validación `exp`).
- Login / registro con validaciones.
- Interceptor 401 → limpia sesión y redirige al Login.
- Resumen de cartera, filtros (todos / por cobrar / cobrados), búsqueda por cliente o DNI.
- Morosidad: préstamos vencidos resaltados en rojo con badge `VENCIDO`.
- Banner de expiración de token (naranja si falta < 1 hora).
- CRUD completo + marcar pagado/pendiente y eliminar con confirmación.
