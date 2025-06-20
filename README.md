# Sistema de Microservicios con NestJS

Este proyecto es un sistema basado en microservicios utilizando [NestJS](https://nestjs.com/), Docker y Prisma ORM. Incluye tres servicios principales:

- **client-gateway**: Puerta de entrada para clientes, maneja la comunicación con los microservicios.
- **orders-ms**: Microservicio para la gestión de órdenes.
- **products-ms**: Microservicio para la gestión de productos.

## Estructura del Proyecto

```
├── client-gateway/
├── orders-ms/
├── products-ms/
├── docker-compose.yml
```

Cada carpeta contiene un microservicio independiente con su propia configuración y dependencias.

## Tecnologías principales

- NestJS
- Docker & Docker Compose
- Prisma ORM
- PostgreSQL

## Requisitos previos

- Node.js >= 18
- Docker y Docker Compose

## Instalación y ejecución

1. Clona el repositorio:
   ```bash
   git clone <url-del-repositorio>
   cd <nombre-del-proyecto>
   ```
2. Levanta los servicios con Docker Compose:
   ```bash
   docker-compose up --build
   ```
3. Cada microservicio puede ejecutarse también de forma individual:
   ```bash
   cd client-gateway && npm install && npm run start:dev
   # o
   cd orders-ms && npm install && npm run start:dev
   # o
   cd products-ms && npm install && npm run start:dev
   ```

## Migraciones de base de datos

Cada microservicio que use Prisma tiene su propio esquema y migraciones:

```bash
cd orders-ms/prisma && npx prisma migrate deploy
cd products-ms/prisma && npx prisma migrate deploy
```

## Endpoints principales

- `client-gateway`: `/api`
- `orders-ms`: `/orders`
- `products-ms`: `/productos`

## Notas

- Modifica las variables de entorno en los archivos `.env` de cada microservicio según tu configuración local.
- Consulta la documentación interna de cada microservicio para detalles específicos.

---

Desarrollado con ❤️ usando NestJS y Docker.
