# Microservicios Launcher con NestJS, Docker y Prisma

<p align="center">
  <img src="https://nestjs.com/img/logo_text.svg" alt="NestJS" height="40"/>
  <img src="https://raw.githubusercontent.com/docker-library/docs/master/docker/logo.png" alt="Docker" height="40"/>
  <img src="https://www.prisma.io/images/og-image.png" alt="Prisma" height="40"/>
  <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL" height="40"/>
  <img src="https://nats.io/img/nats-icon-color.png" alt="NATS" height="40"/>
  <img src="https://stripe.com/img/v3/home/twitter.png" alt="Stripe" height="40"/>
  <img src="https://avatars.githubusercontent.com/u/62738636?s=200&v=4" alt="Hookdeck" height="40"/>
</p>

<p align="center">
  <a href="https://nestjs.com"><img src="https://img.shields.io/badge/NestJS-EA2845?style=for-the-badge&logo=nestjs&logoColor=white"/></a>
  <a href="https://www.docker.com/"><img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white"/></a>
  <a href="https://www.prisma.io/"><img src="https://img.shields.io/badge/Prisma-2D3748?style=for-the-badge&logo=prisma&logoColor=white"/></a>
  <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white"/></a>
  <a href="https://nats.io/"><img src="https://img.shields.io/badge/NATS-1D8FCD?style=for-the-badge&logo=nats.io&logoColor=white"/></a>
  <a href="https://stripe.com/"><img src="https://img.shields.io/badge/Stripe-635BFF?style=for-the-badge&logo=stripe&logoColor=white"/></a>
  <a href="https://hookdeck.com/"><img src="https://img.shields.io/badge/Hookdeck-1A1A1A?style=for-the-badge&logo=hookdeck&logoColor=white"/></a>
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/NestJs-Curso/microservices-launcher/main/.github/stack-diagram.png" alt="Arquitectura Microservicios" width="600"/>
</p>

## Tabla de Contenidos

- [Arquitectura](#arquitectura)
- [Descripción de los Microservicios](#descripción-de-los-microservicios)
- [Flujo de Comunicación](#flujo-de-comunicación)
- [Servicios Incluidos](#servicios-incluidos)
- [Tecnologías Principales](#tecnologías-principales)
- [Requisitos Previos](#requisitos-previos)
- [Instalación y Ejecución](#instalación-y-ejecución)
- [Variables de Entorno](#variables-de-entorno)
- [Ejemplo de .env](#ejemplo-de-env)
- [Migraciones de Base de Datos](#migraciones-de-base-de-datos)
- [Endpoints Principales](#endpoints-principales)
- [Hot Reload y Desarrollo](#hot-reload-y-desarrollo)
- [Integración de Webhooks con Hookdeck](#integración-de-webhooks-con-hookdeck)
- [Agregar Submódulos de GitHub](#agregar-submodulos-de-github)
- [Guía de Troubleshooting](#guía-de-troubleshooting)
- [Guía de Actualización de Submódulos](#guía-de-actualización-de-submódulos)
- [Integración Continua y Despliegue](#integración-continua-y-despliegue)
- [Licencias de Submódulos](#licencias-de-submódulos)
- [Contacto y Soporte](#contacto-y-soporte)
- [Despliegue en Producción](#despliegue-en-producción)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)

---

# Arquitectura

El sistema está compuesto por varios microservicios principales, comunicados mediante NATS (mensajería asíncrona) y expuestos a través de una puerta de enlace (API Gateway). Además, se incluye un servicio para la gestión de pagos y un listener de webhooks con Hookdeck:

```
        ┌────────────────────┐
        │   Cliente/API     │
        └─────────┬────────┘
                  │ HTTP
        ┌─────────▼────────┐
        │  client-gateway │
        └──────┬─────┬─────┬─────┐
               │     │     │     │
         NATS  │     │  NATS│  NATS
        ┌──────▼──┐ ┌▼─────────┐ ┌▼─────────────┐
        │orders-ms│ │products-ms│ │payments-ms  │
        └─────────┘ └──────────┘ └─────────────┘

        ┌─────────────┐
        │  Hookdeck   │
        └─────┬───────┘
              │ Webhook
        ┌─────▼─────────────┐
        │client-gateway/api │
        └───────────────────┘
```

- **client-gateway**: API Gateway para clientes externos.
- **orders-ms**: Microservicio de gestión de órdenes.
- **products-ms**: Microservicio de gestión de productos.
- **payments-ms**: Microservicio de pagos (integración con Stripe).
- **hookdeck**: Servicio para recibir y redirigir webhooks externos (ej. Stripe) hacia el API Gateway.

La comunicación entre los microservicios se realiza principalmente mediante NATS, permitiendo un flujo de mensajes eficiente y desacoplado.

## Descripción de los Microservicios

- **client-gateway**: Orquesta y enruta solicitudes externas hacia los microservicios internos. Expone la API pública (`/api`).
- **orders-ms**: Gestiona el ciclo de vida de las órdenes (creación, actualización, consulta, etc.). Expone `/orders`.
- **products-ms**: Administra productos, inventario y operaciones relacionadas. Expone `/productos`.
- **payments-ms**: Gestiona pagos y la integración con Stripe. Expone `/payments`.
- **hookdeck**: Listener de webhooks, útil para desarrollo local y pruebas con servicios externos como Stripe.

## Flujo de Comunicación

- Los clientes interactúan únicamente con `client-gateway`.
- La comunicación entre microservicios se realiza mediante NATS (mensajería asíncrona) y, en algunos casos, HTTP.
- Los webhooks externos (ej. Stripe) llegan a Hookdeck y son redirigidos al endpoint correspondiente en el API Gateway.
- Cada microservicio es responsable de su propia lógica y persistencia.

## Servicios Incluidos

- `client-gateway/`: Puerta de entrada, orquesta y enruta solicitudes.
- `orders-ms/`: CRUD de órdenes, lógica de negocio y persistencia.
- `products-ms/`: CRUD de productos, lógica de negocio y persistencia.
- `payments-ms/`: Gestión de pagos y webhooks de Stripe.
- `hookdeck/`: Listener de webhooks para desarrollo local.

Cada servicio es independiente, con su propio entorno, dependencias y base de datos (Prisma).

## Tecnologías Principales

- **NestJS** (TypeScript)
- **Docker & Docker Compose**
- **Prisma ORM**
- **PostgreSQL**
- **NATS** (mensajería entre servicios)
- **Hookdeck** (webhooks)
- **Stripe** (pagos)

## Requisitos Previos

- Node.js >= 18
- Docker y Docker Compose
- Git

## Instalación y Ejecución

1. **Clona el repositorio:**
   ```bash
   git clone <url-del-repositorio>
   cd microservices-launcher
   ```
2. **Configura las variables de entorno:**
   Copia los archivos `.env.example` de cada microservicio a `.env` y ajusta según tu entorno local.
   ```bash
   cp client-gateway/.env.example client-gateway/.env
   cp orders-ms/.env.example orders-ms/.env
   cp products-ms/.env.example products-ms/.env
   cp payments-ms/.env.example payments-ms/.env
   ```
3. **Levanta todos los servicios con Docker Compose:**
   ```bash
   docker compose up --build
   ```
   Esto construirá y levantará todos los microservicios, bases de datos asociadas y el listener de webhooks (Hookdeck).
4. **Ejecución individual (opcional):**
   Si deseas trabajar en un microservicio de forma aislada:
   ```bash
   cd <servicio>
   npm install
   npm run start:dev
   ```

## Variables de Entorno

Cada microservicio requiere su propio archivo `.env` con las siguientes variables principales:

- `DATABASE_URL`: Cadena de conexión a PostgreSQL
- `NATS_URL`: URL del servidor NATS
- Variables de Stripe para pagos (`STRIPE_SECRET`, `STRIPE_SUCCESS_URL`, etc.)
- Otros según la lógica de cada microservicio

Consulta los archivos `.env.example` para más detalles.

## Ejemplo de .env

```env
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db
NATS_URL=nats://localhost:4222
STRIPE_SECRET=sk_test_xxx
STRIPE_SUCCESS_URL=http://localhost:3000/success
STRIPE_CANCEL_URL=http://localhost:3000/cancel
# Otras variables específicas del microservicio
```

## Migraciones de Base de Datos

Para aplicar las migraciones de Prisma en cada microservicio:

```bash
cd orders-ms/prisma && npx prisma migrate deploy
cd products-ms/prisma && npx prisma migrate deploy
cd payments-ms/prisma && npx prisma migrate deploy
```

## Endpoints Principales

- **client-gateway**: `/api`
- **orders-ms**: `/orders`
- **products-ms**: `/productos`
- **payments-ms**: `/payments`
- **webhooks**: `/webhooks` (recibe eventos desde Hookdeck)

Consulta la documentación interna de cada microservicio para detalles de endpoints y payloads.

## Hot Reload y Desarrollo

- Todos los microservicios están configurados para hot reload usando `npm run start:dev` y volúmenes Docker.
- Si usas Docker en Windows/WSL y tienes problemas con el watcher, puedes agregar la opción `--watch --poll=1000` en el comando de NestJS.
- Los cambios en el código fuente se reflejan automáticamente en los contenedores sin necesidad de reconstruir la imagen.

## Integración de Webhooks con Hookdeck

- El servicio `hookdeck` se levanta automáticamente con Docker Compose.
- Hookdeck permite recibir webhooks de servicios externos (ej. Stripe) y redirigirlos a tu API Gateway local.
- Personaliza el comando de Hookdeck en `docker-compose.yml`:
  ```yaml
  hookdeck:
    image: hookdeck/cli:latest
    command: listen --source stripe --destination http://client-gateway:3000/webhooks/stripe --token tu_token_real
    depends_on:
      - client-gateway
      - products-service
      - orders-service
      - payments-service
    environment:
      - HOOKDECK_CONFIG_DIR=/data
    volumes:
      - ./hookdeck-data:/data
  ```
- Reemplaza `stripe` y `tu_token_real` por tus valores reales.

## Agregar Submódulos de GitHub

Si deseas agregar más microservicios o componentes como submódulos de otros repositorios de GitHub, sigue estos pasos:

1. Posiciónate en la raíz del proyecto.
2. Ejecuta el siguiente comando para agregar el submódulo:
   ```bash
   git submodule add <url-del-repositorio> <carpeta-destino>
   ```
   Por ejemplo:
   ```bash
   git submodule add https://github.com/usuario/mi-microservicio.git mi-microservicio
   ```
3. Inicializa y actualiza los submódulos:
   ```bash
   git submodule update --init --recursive
   ```
4. Para clonar el proyecto con todos los submódulos en el futuro:
   ```bash
   git clone --recurse-submodules <url-del-repositorio-principal>
   ```

## Guía de Troubleshooting

- **Error de conexión a la base de datos:** Verifica las variables `DATABASE_URL` y que el contenedor de PostgreSQL esté corriendo.
- **Puertos ocupados:** Cambia los puertos en los archivos `.env` o en `docker-compose.yml`.
- **Problemas con NATS:** Asegúrate de que el servicio NATS esté levantado y la URL sea correcta.
- **Problemas con Stripe/Hookdeck:** Verifica que el token y la fuente sean correctos y que el endpoint de destino esté disponible.
- **Dependencias faltantes:** Ejecuta `npm install` en el microservicio correspondiente.

## Guía de Actualización de Submódulos

Para actualizar un submódulo a la última versión de su rama principal:

```bash
git submodule update --remote <carpeta-submodulo>
```

Luego haz commit de los cambios en el submódulo:

```bash
git add <carpeta-submodulo>
git commit -m "update submodule <carpeta-submodulo>"
```

## Integración Continua y Despliegue

- Se recomienda configurar pipelines de CI/CD (por ejemplo, GitHub Actions, GitLab CI) para automatizar tests, builds y despliegues.
- Para producción, utiliza imágenes Docker optimizadas y orquestadores como Kubernetes.
- Configura monitoreo (Prometheus, Grafana) y logging centralizado (ELK, Loki, etc.).

## Licencias de Submódulos

Si agregas submódulos, revisa y respeta las licencias de cada uno. Pueden tener requisitos distintos a la licencia principal de este repositorio.

## Contacto y Soporte

Para reportar bugs, solicitar soporte o sugerir mejoras, abre un issue en este repositorio o contacta a los mantenedores.

## Despliegue en Producción

- Ajusta las variables de entorno para producción.
- Utiliza imágenes Docker optimizadas y orquestadores como Kubernetes si es necesario.
- Configura monitoreo y logging centralizado.

## Contribuciones

¡Las contribuciones son bienvenidas! Por favor, abre un issue o pull request siguiendo las buenas prácticas de desarrollo colaborativo.

## Licencia

Este proyecto está bajo la licencia MIT.

---

Desarrollado con ❤️ por la comunidad usando NestJS, Docker y buenas prácticas de microservicios.
