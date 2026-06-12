# Deploy del Portal

El portal es **estático** (lo sirve nginx) y concentra el ruteo a todas las apps.
No tiene proceso propio: solo archivos + configuración de nginx. Cada app corre en
su propio puerto local y se publica bajo un subpath.

## Mapa de puertos

| App | Subpath | Puerto | Stack | Unit |
|---|---|---|---|---|
| Cotizaciones | `/cotizaciones/` | 8501 | Streamlit | en repo COTIZACIONES |
| RRHH | `/rrhh/` | 8502 | Streamlit | en repo RRHH |
| Control de Flota | `/flota/` | 8503 | Streamlit | `services/flota-app.service` |
| Certificaciones | `/certificaciones/` | 8504 | Streamlit (+ backend) | `services/certificaciones-app.service` |
| Inspecciones | https://inspecciones.americanad.ar | — | Streamlit (externa) | la tarjeta enlaza al dominio; no se proxea |
| Informes Médicos | `/informes/` | 8506 | Streamlit | `services/informes-app.service` |
| ~~8505~~ | — | libre | — | (liberado al ser Inspecciones externa) |
| Capacitaciones | `/capacitaciones/` | 8507 | Streamlit (+ FastAPI) | `services/capacitaciones-app.service` |
| Asistente | `/asistente/` | — | PHP | *próximamente* |
| Campus / Moodle | `/campus/` | — | Flask | *próximamente* |
| Salud (HIS) | `/salud/` | — | Django | *próximamente* |
| ANMAT / Trazamed | `/anmat/` | — | .NET | *próximamente* |

> Los units de Cotizaciones y RRHH viven en **sus** repos (ya desplegados). Los 5
> nuevos se versionan acá en `deploy/services/` porque esos repos no tienen git propio.

## 1. Instalar el portal (menú + ruteo nginx)

```bash
cd /root
git clone https://github.com/sarmientojulioe/portal.git portal
cd /root/portal
sudo bash deploy/install.sh          # publica el menú, instala nginx, valida y recarga
```

Editá `server_name` en `/etc/nginx/sites-available/portal` si tenés dominio.

## 2. Desplegar cada app Streamlit nueva

Patrón idéntico para las 5 (cambian carpeta/puerto). Ejemplo con **Flota**:

```bash
# Traer el código a /root/<app>  (git clone o copia)
cd /root && git clone <URL-o-copia> flota
cd /root/flota
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
# Si la app necesita credenciales/DB, crear su .env / secrets aquí.

# Instalar el servicio (unit versionado en el portal)
sudo cp /root/portal/deploy/services/flota-app.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now flota-app
ss -tlnp | grep 8503                 # debe escuchar en 127.0.0.1:8503
```

Rutas/carpeta por app (ver cada `.service` para el detalle exacto):

| App | clonar en | WorkingDirectory | requirements |
|---|---|---|---|
| Flota | `/root/flota` | `/root/flota` | `requirements.txt` (raíz) |
| Certificaciones | `/root/certificaciones` | `/root/certificaciones/frontend` | revisar `frontend/` o raíz |
| Informes | `/root/informes` | `/root/informes/CENTRO MEDICO` | en esa carpeta |
| Capacitaciones | `/root/capacitaciones` | `/root/capacitaciones/frontend` | `frontend/` |

### Dependencias de backend (importante)

- **Certificaciones** y **Capacitaciones** tienen un **backend propio** (FastAPI +
  Supabase / API). El frontend Streamlit funciona pero **necesita su backend
  corriendo** para no dar errores. Hay que levantar ese backend como otro servicio
  (no expuesto por el portal, solo interno). Pendiente de definir por app.
- **Inspecciones** ya está **productiva y externa** en `https://inspecciones.americanad.ar`
  (Streamlit con SQL Anywhere). El portal solo enlaza; no la hostea.

## 3. Apps "próximamente" (otros stacks)

Asistente (PHP), Campus/Moodle (Flask), Salud (Django) y ANMAT (.NET) figuran como
tarjetas deshabilitadas en el menú. Cada una se integra aparte porque el subpath
exige config propia del framework:

- **Flask:** `APPLICATION_ROOT=/campus` + `ProxyFix`.
- **Django:** `FORCE_SCRIPT_NAME=/salud` + `USE_X_FORWARDED_HOST`.
- **PHP (php-fpm):** `location ~ \.php$` con `fastcgi_param SCRIPT_NAME`.
- **.NET (Kestrel):** `UsePathBase("/anmat")`.

Cuando se integre una, se agrega su `location` en `portal.nginx.conf` y se pasa su
tarjeta de `estado:"off"` a `"dev"` en `site/index.html`.

## Sumar una app nueva (resumen)

1. Que corra con `--server.baseUrlPath=<path>` y un puerto libre.
2. `location ^~ /<path>/` en `deploy/portal.nginx.conf` (hay plantilla al final).
3. Tarjeta en el registro `APPS` de `site/index.html`.
4. `git pull` en la VM + `sudo bash deploy/install.sh`.

## HTTPS (opcional)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d portal.tudominio.com
```
