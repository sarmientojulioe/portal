# Deploy del Portal

El portal es un **sitio estático** (un menú) servido por nginx en su propio
subdominio. **No proxea las apps**: cada app vive en su propio
`<app>.americanad.ar` y el portal solo enlaza.

```
portal.americanad.ar         → /var/www/portal (este menú)
cotizaciones.americanad.ar   → app Cotizaciones
rrhh.americanad.ar           → app RRHH
flota.americanad.ar          → app Control de Flota
inspecciones.americanad.ar   → app Inspecciones (Easypanel)
```

## Infraestructura (resumen)

| Servidor | IP | Rol |
|---|---|---|
| VPS nginx | `165.227.80.93` | Reverse-proxy + SSL de los subdominios `*.americanad.ar` |
| Host de apps | `172.16.18.101` (túnel WireGuard) | Donde corren las apps Streamlit (puertos 85xx) |
| Easypanel | `167.71.125.132` | Apps dockerizadas con auto-deploy (Inspecciones) |
| Plesk/IIS | `190.105.235.107` | Sitios `*.americanad.com.ar` + redirecciones 301 |

DNS de `*.americanad.ar` en **DonWeb** (registros A → `165.227.80.93`).

## 1. Publicar el portal

```bash
cd /root && git clone https://github.com/sarmientojulioe/portal.git portal
cd /root/portal
sudo bash deploy/install.sh
# DNS:  A  portal.americanad.ar -> 165.227.80.93
sudo certbot --nginx -d portal.americanad.ar
```

Para actualizar el menú: `git pull` + `sudo bash deploy/install.sh`.

## 2. Publicar una app en su subdominio

Patrón (documentado en `deploy/template-subdominio.conf`):

1. **DNS** en DonWeb: `A  <app>.americanad.ar → 165.227.80.93`.
2. Copiar `template-subdominio.conf` a `/etc/nginx/sites-available/<app>` y
   reemplazar `SUBDOMINIO`, `IP_APP`, `PUERTO`.
3. `ln -s` a `sites-enabled` + `nginx -t` + `reload`.
4. `sudo certbot --nginx -d <app>.americanad.ar`.
5. Pasar la tarjeta de `estado:"dev"` a `"ok"` en `site/index.html` (y
   `git pull` + `install.sh` para refrescar el menú).

> La app en sí corre en el host de apps (`172.16.18.101`) como servicio propio
> (systemd/docker), escuchando en su puerto, **sin** baseUrlPath (se sirve en la
> raíz de su subdominio). El service de cada app vive en SU repo.

## Estado actual

| App | Subdominio | Estado |
|---|---|---|
| Cotizaciones | `cotizaciones.americanad.ar` | ✅ publicada |
| RRHH | `rrhh.americanad.ar` | ✅ publicada |
| Control de Flota | `flota.americanad.ar` | ✅ publicada |
| Inspecciones | `inspecciones.americanad.ar` | ✅ publicada (Easypanel) |
| Certificaciones | `certificaciones.americanad.ar` | 🛠 en desarrollo |
| Informes Médicos | `informes.americanad.ar` | 🛠 en desarrollo |
| Capacitaciones | `capacitaciones.americanad.ar` | 🛠 en desarrollo |
| Asistente / Campus / Salud / ANMAT | — | ⏳ próximamente (otros stacks) |
