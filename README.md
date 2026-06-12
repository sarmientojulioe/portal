# Portal de Aplicaciones — American Advisor

Puerta de entrada única a las aplicaciones internas. Es un menú **estático**
(servido por nginx en `portal.americanad.ar`) que funciona como **directorio**:
cada app vive en su propio subdominio `<app>.americanad.ar` y el portal enlaza.

```
portal.americanad.ar
 ├── Cotizaciones    → https://cotizaciones.americanad.ar   ✅
 ├── RRHH            → https://rrhh.americanad.ar            ✅
 ├── Control de Flota→ https://flota.americanad.ar           ✅
 ├── Inspecciones    → https://inspecciones.americanad.ar    ✅
 ├── Certificaciones → certificaciones.americanad.ar         🛠 en desarrollo
 ├── Informes Médicos→ informes.americanad.ar                🛠 en desarrollo
 └── Capacitaciones  → capacitaciones.americanad.ar          🛠 en desarrollo
```

Próximamente (otros stacks): Asistente IA (widget en emicar/americanad), Campus
/ Moodle (Flask), Salud / HIS (Django), ANMAT / Trazamed (.NET).

## Estructura

```
PORTAL/
├── site/
│   ├── index.html              # menú (registro APPS editable)
│   └── assets/                 # logo + certificaciones IRAM-ISO
├── brand/ Manual de marca.pdf  # referencia
└── deploy/
    ├── portal.nginx.conf       # server block del portal (sitio estático)
    ├── template-subdominio.conf# plantilla para publicar una app en su subdominio
    ├── install.sh              # instalador idempotente
    └── README.md               # despliegue + patrón de subdominios
```

## Modelo

- **Una app = un subdominio** (`app.americanad.ar`), con su server block nginx y
  su SSL (certbot). Es el patrón real de la infra.
- El portal **solo enlaza** (no proxea). Sumar/activar una app = editar el
  registro `APPS` de `site/index.html` y pasar su `estado` a `"ok"`.
- Solo las tarjetas `estado:"ok"` son clicables; `dev`/`off` se muestran
  deshabilitadas.

## Desarrollo local (Windows)

Abrí `site/index.html` en el navegador: el menú se ve sin levantar nada (el
registro está embebido en el HTML).

## Deploy

Ver [`deploy/README.md`](deploy/README.md).
