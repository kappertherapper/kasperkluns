import Vapor
import PostgresKit

func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
    
    app.get("products", ":id") { request in
        let id = request.parameters.get("id") ?? "no id provided"
        return "returning product with id: \(id)"
    }
    
    app.get("test-minimal") { req async throws in
        guard let db = req.db as? (any SQLDatabase) else {
            throw Abort(.internalServerError, reason: "Database is not SQL")
        }
        
        try await db.raw("INSERT INTO products (id, name, sku, brand) VALUES (gen_random_uuid(), 'test', 999, 'NewBalance'::brand)").run()
        return "Success"
    }
    
    try app.register(collection: ProductController())
}
