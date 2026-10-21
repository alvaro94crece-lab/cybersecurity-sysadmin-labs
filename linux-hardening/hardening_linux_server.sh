#!/bin/bash

# ==============================================================================
# SCRIPT: hardening_linux_server.sh
# AUTOR: Álvaro Blanco Garay
# DESCRIPCIÓN: Script de bastionado y fortificación básica para servidores
#              Linux (Ubuntu/Debian). Configura UFW, SSH, Fail2ban y Kernel.
# ==============================================================================

# Comprobar que el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "[ERROR] Este script debe ejecutarse con privilegios de root (sudo)."
  exit 1
fi

LOG_FILE="/var/log/hardening_execution.log"
FECHA=$(date "+%Y-%m-%d %H:%M:%S")

echo "=================================================" | tee -a "$LOG_FILE"
echo " Iniciando Bastionado del Servidor - $FECHA" | tee -a "$LOG_FILE"
echo "=================================================" | tee -a "$LOG_FILE"

# 1. Actualización de paquetes de seguridad
echo "[+] Actualizando repositorios y paquetes de seguridad..." | tee -a "$LOG_FILE"
apt-get update -y && apt-get upgrade -y >> "$LOG_FILE" 2>&1

# 2. Instalación y configuración de Cortafuegos (UFW)
echo "[+] Instalando y configurando UFW (Uncomplicated Firewall)..." | tee -a "$LOG_FILE"
apt-get install ufw -y >> "$LOG_FILE" 2>&1
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH Seguro'
ufw allow 80/tcp comment 'HTTP Web'
ufw allow 443/tcp comment 'HTTPS Web'
ufw --force enable >> "$LOG_FILE" 2>&1

# 3. Fortificación de SSH (sshd_config)
echo "[+] Fortificando configuración del servicio SSH..." | tee -a "$LOG_FILE"
SSH_CONFIG="/etc/ssh/sshd_config"
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak"

# Deshabilitar login directo de root y limitar intentos
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' "$SSH_CONFIG"
sed -i 's/^#*MaxAuthTries.*/MaxAuthTries 3/' "$SSH_CONFIG"
sed -i 's/^#*ClientAliveInterval.*/ClientAliveInterval 300/' "$SSH_CONFIG"

systemctl restart sshd >> "$LOG_FILE" 2>&1

# 4. Instalación de Fail2ban (Protección anti Fuerza Bruta)
echo "[+] Instalando y activando Fail2ban..." | tee -a "$LOG_FILE"
apt-get install fail2ban -y >> "$LOG_FILE" 2>&1
systemctl enable fail2ban >> "$LOG_FILE" 2>&1
systemctl start fail2ban >> "$LOG_FILE" 2>&1

# 5. Bastionado básico del Kernel (sysctl.conf)
echo "[+] Aplicando reglas de bastionado en el Kernel (Red)..." | tee -a "$LOG_FILE"
SYSCTL_CONF="/etc/sysctl.conf"
echo "net.ipv4.tcp_syncookies = 1" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.all.accept_redirects = 0" >> "$SYSCTL_CONF"
echo "net.ipv4.conf.all.send_redirects = 0" >> "$SYSCTL_CONF"
sysctl -p >> "$LOG_FILE" 2>&1

echo "=================================================" | tee -a "$LOG_FILE"
echo "[ÉXITO] Bastionado completado correctamente." | tee -a "$LOG_FILE"
echo "=================================================" | tee -a "$LOG_FILE"
