# Portal de Aplicaciones — American Advisor

Puerta de entrada única a las aplicaciones internas en desarrollo. Es un menú
**estático** servido por nginx que rutea a cada app (Streamlit) bajo su subpath.

```
http://<IP_o_dominio>/              → menú
http://<IP_o_dominio>/cotizaciones/ → app Cotizaciones (:8501)
http://<IP_o_dominio>/rrhh/         → app RRHH (:8502)
```

## Estructura

```
PORTAL/
├── site/
│   └── index.html          # menú (incluye el registro APPS, editable)
└── deploy/
    ├── portal.nginx.conf       # server block: raíz + proxys a cada app
    ├── nginx-websocket-map.conf# map de websockets (Streamlit)
    ├── install.sh              # instalador idempotente para la VM
    └── README.md               # pasos de despliegue
```

## Desarrollo local (Windows)

Abrí `site/index.html` en el navegador. El registro de apps está embebido en el
propio HTML (`const APPS = [...]`), así que el menú se ve sin levantar nada. Los
links a `/cotizaciones/` y `/rrhh/` solo resuelven detrás de nginx en la VM.

## Filosofía

- **Una sola fuente de ruteo:** todo el nginx vive acá; cada app solo conoce su
  propio servicio systemd y su puerto.
- **Sumar una app = 2 ediciones acá** (una `location` y una tarjeta) + que la app
  arranque con su `baseUrlPath`. Ver `deploy/README.md`.

## Deploy

Ver [`deploy/README.md`](deploy/README.md).
