import Vapor

struct ProductController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let products = routes.grouped("products")
        
        // Create
        products.post { request in
            try await createProduct(request: request)
        }
        
        // Read
        products.get { request in
            try await getProducts(request: request)
        }
    
        products.get(":id") { request in
            try await getProduct(request: request)
        }
        
        // Update
        products.put(":id") { request in
            try await updateProduct(request: request)
        }
        
        // Delete
        products.delete(":id") { request in
            try await deleteProduct(request: request)
        }
    }
    // MARK: - CREATE
    
    @Sendable
    private func createProduct(request: Request) async throws -> ProductResponseContent {
        let requestContent = try request.content.decode(ProductRequestContent.self)
        guard let name = requestContent.name else {
            throw Abort(.badRequest, reason: "Name is required")
        }
        
        guard let sku = requestContent.sku else {
            throw Abort(.badRequest, reason: "Name is required")
        }
        
        let product = Product(requestContent: requestContent, name: name, sku: sku)
        try await product.save(on: request.db)
        
        return try ProductResponseContent(product: product)
    }
    
    // MARK: - READ
    
    private func getProducts(request: Request) async throws -> [ProductResponseContent] {
        let products: [Product] = try await Product.query(on: request.db).all()
        return try products.map { product in
            try ProductResponseContent(product: product)
        }
    }
    
    private func getProduct(request: Request) async throws -> ProductResponseContent {
        let id: UUID? = request.parameters.get("id")
        
        guard let product = try await  Product.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        return try ProductResponseContent(product: product)
    }
    
    // MARK: - UPDATE
    
    @Sendable
    private func updateProduct(request: Request) async throws -> ProductResponseContent {
        let id: UUID? = request.parameters.get("id")
        
        guard let product = try await  Product.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        let requestContent = try request.content.decode(ProductRequestContent.self)
        product.setvalue(requestContent.name, to: \.name)
        product.setvalue(requestContent.description, to: \.description)
        product.setBrand(requestContent.brand)
        try await product.update(on: request.db)
        
        return try ProductResponseContent(product: product)
    }
    
    
    //MARK: - DELETE
    
    private func deleteProduct(request: Request) async throws -> HTTPStatus {
        let id: UUID? = request.parameters.get("id")
        
        guard let product = try await  Product.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        try await product.delete(on: request.db)
       
        return HTTPStatus.noContent
    }
}

// MARK: - Private helpers

private extension Product {
    func setvalue<Value>(
        _ value: Value?,
        to keyPath: ReferenceWritableKeyPath<Product, Value>
    ) {
        if let value {
            self[keyPath: keyPath] = value
        }
    }
    
    func setBrand (_ brandRawValue: String?) {
        if let brandRawValue {
            brand = Brand(rawValue: brandRawValue)
        }
    }
}
