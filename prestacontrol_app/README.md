# PrestaControl App (Flutter)

Aplicación móvil Flutter (Material 3) para consumir la API PrestaControl.

## Configuración rápida
1. Instalar dependencias:
   ```bash
   flutter pub get
   ```
2. Configurar URL de API en `lib/config/api_config.dart`:
   - Emulador Android: `http://10.0.2.2:8080`
   - Dispositivo físico: `http://<IP_LOCAL>:8080`
   - Render: `https://<tu-servicio>.onrender.com`
3. Ejecutar:
   ```bash
   flutter run
   ```

## Funcionalidades
- Splash con sesión persistente (`flutter_secure_storage` + validación `exp` JWT).
- Login y registro con validaciones y manejo de errores.
- Interceptor HTTP 401: limpia sesión, muestra SnackBar y redirige a Login.
- Home con resumen de cartera (`/prestamos/resumen`).
- Filtros: Todos / Por cobrar / Cobrados.
- Búsqueda en tiempo real por cliente o DNI.
- Indicador de morosidad: vencidos no pagados resaltados en rojo con badge `VENCIDO`.
- Banner de expiración de token (alerta naranja si falta < 1 hora).
- CRUD completo: crear, editar, marcar pagado/pendiente, eliminar con confirmación.
