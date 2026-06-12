# Deploy del Portal

El portal es **estático** (lo sirve nginx) y concentra el ruteo a todas las apps.
No tiene proceso propio: solo archivos + configuración de nginx.

```
nginx :80
 ├── /              → /var/www/portal  (menú estático)
 ├── /cotizaciones/ → 127.0.0.1:8501   (app, baseUrlPath=cotizaciones)
 └── /rrhh/         → 127.0.0.1:8502   (app, baseUrlPath=rrhh)
```

## Requisitos previos

Cada app debe correr en su puerto local y arrancar con su `baseUrlPath`:

| App | Puerto | Flag de arranque |
|---|---|---|
| Cotizaciones | 8501 | `--server.baseUrlPath=cotizaciones` (en su `cotizaciones-app.service`) |
| RRHH | 8502 | `--server.baseUrlPath=rrhh` (en su `rrhh-app.service`) |

> El servicio systemd de cada app vive en **su** repo (`deploy/*.service`). El
> portal solo rutea; no arranca las apps.

## Instalar / actualizar (en la VM)

```bash
cd /root
git clone <URL-del-repo-PORTAL> portal      # o git pull si ya existe
cd /root/portal
sudo bash deploy/install.sh
```

`install.sh` copia el menú a `/var/www/portal`, instala el `map` de websockets,
enlaza el sitio `portal`, valida (`nginx -t`) y recarga. Editá `server_name` en
`/etc/nginx/sites-available/portal` si tenés dominio.

## Sumar una app nueva

1. **En la app:** que corra con `--server.baseUrlPath=<path>` y un puerto libre.
2. **En el portal:** agregá su `location ^~ /<path>/` en `deploy/portal.nginx.conf`
   (hay una plantilla comentada al final) y una tarjeta en el registro `APPS` de
   `site/index.html`.
3. `git pull` en la VM + `sudo bash deploy/install.sh`.

## HTTPS (opcional)

Con dominio apuntando a la VM:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d portal.tudominio.com
```
