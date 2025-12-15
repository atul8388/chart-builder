<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="200" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://coveralls.io/github/nestjs/nest?branch=master" target="_blank"><img src="https://coveralls.io/repos/github/nestjs/nest/badge.svg?branch=master#9" alt="Coverage" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

A ready-to-use NestJS API project with TypeORM configured for SQL database connection.

### Features

- ✅ NestJS framework
- ✅ TypeORM integration
- ✅ MSSQL (SQL Server) database support (easily switchable to PostgreSQL, MySQL, etc.)
- ✅ Environment configuration
- ✅ Sample User CRUD API
- ✅ Auto-synchronization of database schema (development mode)

## Prerequisites

- Node.js (v14 or higher)
- Microsoft SQL Server (MSSQL) database server running
- npm package manager

## Installation

```bash
$ npm install
```

## Database Setup

1. Configure your database by updating the `.env` file:

   ```
   DB_TYPE=mssql
   DB_HOST=localhost
   DB_PORT=1433
   DB_USERNAME=sa
   DB_PASSWORD=your_password
   DB_DATABASE=your_database_name
   ```

2. Create the database in SQL Server:
   ```sql
   CREATE DATABASE nestjs_db;
   ```

## Running the app

```bash
# development
$ npm run start

# watch mode (recommended for development)
$ npm run start:dev

# production mode
$ npm run start:prod
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Users API (Sample)

- **GET** `/users` - Get all users
- **GET** `/users/:id` - Get a user by ID
- **POST** `/users` - Create a new user
  ```json
  {
    "name": "John Doe",
    "email": "john@example.com",
    "isActive": true
  }
  ```
- **PATCH** `/users/:id` - Update a user
- **DELETE** `/users/:id` - Delete a user

### Testing the API

```bash
# Create a user
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'

# Get all users
curl http://localhost:3000/users
```

## Project Structure

```
src/
├── users/                  # Users module (sample)
│   ├── dto/               # Data Transfer Objects
│   ├── user.entity.ts     # User entity (database model)
│   ├── users.controller.ts # Users controller (routes)
│   ├── users.service.ts   # Users service (business logic)
│   └── users.module.ts    # Users module
├── app.module.ts          # Root module with TypeORM config
└── main.ts                # Application entry point
```

## Database Configuration

### Switching to MySQL

1. Install MySQL driver:

```bash
npm uninstall mssql
npm install mysql2
```

2. Update `.env`:

```
DB_TYPE=mysql
DB_PORT=3306
```

### Switching to PostgreSQL

1. Install PostgreSQL driver:

```bash
npm uninstall mssql
npm install pg
```

2. Update `.env`:

```
DB_TYPE=postgres
DB_PORT=5432
```

### MSSQL Connection Options

The project is configured with the following MSSQL options in `app.module.ts`:

- `encrypt: false` - Set to `true` if using Azure SQL Database
- `trustServerCertificate: true` - Set to `false` in production with valid SSL certificates

## Important Notes

- **synchronize: true** is enabled in development for auto-schema generation
- **DISABLE synchronize in production** to prevent data loss
- Use migrations for production database changes
- The database logging is enabled for development

## Test

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://kamilmysliwiec.com)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](LICENSE).
