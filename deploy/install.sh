#!/usr/bin/env bash
# Instala/actualiza el portal (sitio estático) en el VPS de nginx. Idempotente.
# Uso:  sudo bash deploy/install.sh
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEB_DIR="/var/www/portal"

echo ">> Publicando el menú estático en ${WEB_DIR}"
mkdir -p "${WEB_DIR}"
cp -r "${REPO_DIR}/site/." "${WEB_DIR}/"

echo ">> Instalando server block 'portal' en nginx"
cp "${REPO_DIR}/deploy/portal.nginx.conf" /etc/nginx/sites-available/portal
ln -sf /etc/nginx/sites-available/portal /etc/nginx/sites-enabled/portal

echo ">> Validando y recargando nginx"
nginx -t
systemctl reload nginx

echo
echo "OK. Portal publicado."
echo "  - Ajustá server_name en /etc/nginx/sites-available/portal si hace falta."
echo "  - DNS: A  portal.americanad.ar -> 165.227.80.93"
echo "  - SSL: sudo certbot --nginx -d portal.americanad.ar"
