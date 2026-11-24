# kasperserver
💧 A project built with the Vapor web framework.

Backend server for the kasperkluns inventory app, a personal inventory management application for second-hand clothing and footwear. 
The server is built with the Vapor web framework in Swift, uses PostgreSQL as database, and manages schema migrations with Fluent.

## Requirements
- Swift toolchain or Docker
- PostgreSQL database

## Running the server
Start the server locally with the Swift Package Manager:
```bash
swift run
```
The API is then served on `http://localhost:8080`.
Alternatively, run the containerized server with Docker Compose:
```bash
docker compose up app
```

## Configuration
The server reads the following environment variables:
| Variable | Default | Description |
| --- | --- | --- |
| `DATABASE_HOST` | `localhost` | PostgreSQL hostname |
| `DATABASE_PORT` | `5432` | PostgreSQL port |
| `DATABASE_USERNAME` | `postgres` | Database user |
| `DATABASE_PASSWORD` | `password` | Database password |
| `DATABASE_NAME` | `vapor_database` | Database name |
| `LOG_LEVEL` | `debug` | Vapor log level |

## API endpoints
- `GET /` and `GET /hello`: health checks
- `GET /backup`: triggers a database backup
- `GET /products/:id`, `PUT /products/:id`, `PATCH /products/:id`, `DELETE /products/:id`: product operations
- `GET /sneakers/:id`, `PUT /sneakers/:id`, `PATCH /sneakers/:id`, `DELETE /sneakers/:id`: sneaker operations

## Tests
Run the test suite with:
```bash
swift test
```
