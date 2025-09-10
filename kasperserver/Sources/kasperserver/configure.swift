import Vapor
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    
    app.http.server.configuration.hostname = "0.0.0.0"
    //app.http.server.configuration.port = 8080

    let config = SQLPostgresConfiguration(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? 5432,
        username: Environment.get("DATABASE_USERNAME") ?? "postgres",
        password: Environment.get("DATABASE_PASSWORD") ?? "password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .disable,
    )
    
    app.databases.use(
           .postgres(
                configuration: config,
                maxConnectionsPerEventLoop: 1,
                connectionPoolTimeout: .seconds(10)
           ),
           as: .psql,
        )
    
    app.migrations.add(CreateProductMigration())
    
    //try await app.autoRevert()
    try await app.autoMigrate()
    try routes(app)

    /*
    // SQL logging
    if !app.environment.isRelease {
        app.logger.logLevel = .debug
    }
    */
}
