# Quick Start Guide

## 1. Setup Database

Make sure Microsoft SQL Server is running and create a database:

```sql
CREATE DATABASE nestjs_db;
```

## 2. Configure Environment

Update the `.env` file with your database credentials:

```env
DB_TYPE=mssql
DB_HOST=localhost
DB_PORT=1433
DB_USERNAME=sa
DB_PASSWORD=your_password
DB_DATABASE=nestjs_db
PORT=3000
```

## 3. Start the Application

```bash
npm run start:dev
```

The API will be running at `http://localhost:3000`

## 4. Test the API

### Create a user:

```bash
curl -X POST http://localhost:3000/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

### Get all users:

```bash
curl http://localhost:3000/users
```

### Get a specific user:

```bash
curl http://localhost:3000/users/1
```

### Update a user:

```bash
curl -X PATCH http://localhost:3000/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe"}'
```

### Delete a user:

```bash
curl -X DELETE http://localhost:3000/users/1
```

## 5. Add Your Own Modules

Follow the pattern in `src/users/` to create new modules:

1. Create entity file (e.g., `product.entity.ts`)
2. Create DTOs in `dto/` folder
3. Create service file (e.g., `products.service.ts`)
4. Create controller file (e.g., `products.controller.ts`)
5. Create module file (e.g., `products.module.ts`)
6. Import the module in `app.module.ts`

That's it! You're ready to build your API.
