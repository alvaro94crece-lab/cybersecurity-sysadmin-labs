# 🛡️ Bastionado de Servidores Linux (Hardening)

Script de automatización en Bash para fortificar y bastionar servidores basados en **Ubuntu / Debian** recién desplegados.

### 📋 Medidas de Seguridad Aplicadas:
1. **Cortafuegos UFW:** Denegación por defecto del tráfico entrante y apertura exclusiva de puertos seguros (SSH 22, HTTP 80, HTTPS 443).
2. **Fortificación SSH:** Deshabilitado el acceso remoto como `root`, restricción a 3 intentos máximos de autenticación y desconexión por inactividad.
3. **Anti-Fuerza Bruta (Fail2ban):** Despliegue de Fail2ban para banear direcciones IP tras intentos fallidos repetidos de acceso.
4. **Protección de Red (Kernel):** Activación de `tcp_syncookies` contra ataques SYN Flood y deshabilitación de redirecciones ICMP.

### 🚀 Modo de Uso:
```bash
chmod +x hardening_linux_server.sh
sudo ./hardening_linux_server.sh
