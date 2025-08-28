import Vapor

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
    
    try app.register(collection: ProductController())
}
