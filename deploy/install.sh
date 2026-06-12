#!/usr/bin/env bash
# Instala/actualiza el portal en la VM. Idempotente.
# Uso:  sudo bash deploy/install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="/var/www/portal"

echo ">> Publicando el menú estático en ${WEB_DIR}"
mkdir -p "${WEB_DIR}"
cp -r "${REPO_DIR}/site/." "${WEB_DIR}/"

echo ">> Instalando map de websockets"
cp "${REPO_DIR}/deploy/nginx-websocket-map.conf" /etc/nginx/conf.d/websocket-map.conf

echo ">> Instalando sitio 'portal' en nginx"
cp "${REPO_DIR}/deploy/portal.nginx.conf" /etc/nginx/sites-available/portal
ln -sf /etc/nginx/sites-available/portal /etc/nginx/sites-enabled/portal

# Si el 'default' de nginx ocupa la raíz, lo desactivamos para no chocar.
if [ -e /etc/nginx/sites-enabled/default ]; then
  echo ">> Desactivando sitio 'default'"
  rm -f /etc/nginx/sites-enabled/default
fi

echo ">> Validando configuración"
nginx -t

echo ">> Recargando nginx"
systemctl reload nginx

echo "OK. Editá server_name en /etc/nginx/sites-available/portal si hace falta."
echo "Portal disponible en http://<IP_o_dominio>/"
