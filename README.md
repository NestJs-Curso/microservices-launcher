# Microservicios Launcher con NestJS, Docker y Prisma

Este repositorio implementa una arquitectura de microservicios moderna utilizando [NestJS](https://nestjs.com/), Docker, Prisma ORM y PostgreSQL. El objetivo es proveer una base escalable y mantenible para sistemas distribuidos, facilitando el desarrollo, despliegue y escalabilidad de servicios independientes.

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
- [Agregar Submódulos de GitHub](#agregar-submodulos-de-github)
- [Guía de Troubleshooting](#guía-de-troubleshooting)
- [Guía de Actualización de Submódulos](#guía-de-actualización-de-submódulos)
- [Integración Continua y Despliegue](#integración-continua-y-despliegue)
- [Licencias de Submódulos](#licencias-de-submódulos)
- [Contacto y Soporte](#contacto-y-soporte)
- [Despliegue en Producción](#despliegue-en-producción)
- [Contribuciones](#contribuciones)
- [Licencia](#licencia)

## Arquitectura

El sistema está compuesto por tres microservicios principales, comunicados mediante NATS (mensajería asíncrona) y expuestos a través de una puerta de enlace (API Gateway):

```
        ┌────────────────────┐
        │   Cliente/API     │
        └─────────┬────────┘
                  │ HTTP
        ┌─────────▼────────┐
        │  client-gateway │
        └──────┬─────┬─────┘
               │     │
         NATS  │     │  NATS
        ┌──────▼──┐ ┌─▼────────┐
        │orders-ms│ │products-ms│
        └─────────┘ └──────────┘
```

- **client-gateway**: API Gateway para clientes externos.
- **orders-ms**: Microservicio de gestión de órdenes.
- **products-ms**: Microservicio de gestión de productos.

La comunicación entre los microservicios se realiza principalmente mediante NATS, permitiendo un flujo de mensajes eficiente y desacoplado.

## Descripción de los Microservicios

- **client-gateway**: Orquesta y enruta solicitudes externas hacia los microservicios internos. Expone la API pública (`/api`).
- **orders-ms**: Gestiona el ciclo de vida de las órdenes (creación, actualización, consulta, etc.). Expone `/orders`.
- **products-ms**: Administra productos, inventario y operaciones relacionadas. Expone `/productos`.

## Flujo de Comunicación

- Los clientes interactúan únicamente con `client-gateway`.
- La comunicación entre microservicios se realiza mediante NATS (mensajería asíncrona) y, en algunos casos, HTTP.
- Cada microservicio es responsable de su propia lógica y persistencia.

## Servicios Incluidos

- `client-gateway/`: Puerta de entrada, orquesta y enruta solicitudes.
- `orders-ms/`: CRUD de órdenes, lógica de negocio y persistencia.
- `products-ms/`: CRUD de productos, lógica de negocio y persistencia.

Cada servicio es independiente, con su propio entorno, dependencias y base de datos (Prisma).

## Tecnologías Principales

- **NestJS** (TypeScript)
- **Docker & Docker Compose**
- **Prisma ORM**
- **PostgreSQL**
- **NATS** (mensajería entre servicios)

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
   ```
3. **Levanta todos los servicios con Docker Compose:**
   ```bash
   docker-compose up --build
   ```
   Esto construirá y levantará todos los microservicios y bases de datos asociadas.
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
- Otros según la lógica de cada microservicio

Consulta los archivos `.env.example` para más detalles.

## Ejemplo de .env

```env
DATABASE_URL=postgresql://usuario:password@localhost:5432/nombre_db
NATS_URL=nats://localhost:4222
# Otras variables específicas del microservicio
```

## Migraciones de Base de Datos

Para aplicar las migraciones de Prisma en cada microservicio:

```bash
cd orders-ms/prisma && npx prisma migrate deploy
cd products-ms/prisma && npx prisma migrate deploy
```

## Endpoints Principales

- **client-gateway**: `/api`
- **orders-ms**: `/orders`
- **products-ms**: `/productos`

Consulta la documentación interna de cada microservicio para detalles de endpoints y payloads.

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
