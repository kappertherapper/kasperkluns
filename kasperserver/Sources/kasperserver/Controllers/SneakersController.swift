import Vapor

struct SneakersController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let sneakers = routes.grouped("sneakers")
        
        // Create
        sneakers.post { request in
            try await createProduct(request: request)
        }
        
        // Read all
        sneakers.get { request in
            try await getProducts(request: request)
        }
    
        // Read one
        sneakers.get(":id") { request in
            try await getProduct(request: request)
        }
        
        // Update
        sneakers.put(":id") { request in
            try await updateProduct(request: request)
        }
        
        // Update sold
        sneakers.patch(":id") { request in
            try await updateProductSold(request: request)
        }
        
        // Delete
        sneakers.delete(":id") { request in
            try await deleteProduct(request: request)
        }
    }
    // MARK: - CREATE
    
    @Sendable
    private func createProduct(request: Request) async throws -> ProductResponseContent {
        let requestContent = try request.content.decode(ProductRequestContent.self)
        
        let name = requestContent.name
        
        let sku = requestContent.sku
        if sku <= 0 { //
            throw Abort(.badRequest, reason: "SKU is required and cant be negative")
        }
        
        let purchasePrice = requestContent.purchasePrice
        if purchasePrice <= 0 { //
            throw Abort(.badRequest, reason: "Price is required and must be higher than zero")
        }
        
        let product = Product(requestContent: requestContent, name: name, sku: sku)
        
        // Log the values being inserted
        //print("Inserting brand value: '\(product.brand?.rawValue ?? "nil")'")
        //print("Brand enum case: \(String(describing: product.brand))")
        
        try await product.saveWithEnumCast(on: request.db)
        
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
        product.setvalue(requestContent.brand, to: \.brand)
        product.setvalue(requestContent.size, to: \.size)
        product.setvalue(requestContent.purchasePrice, to: \.purchasePrice)
        product.setvalue(requestContent.purchaseDate, to: \.purchaseDate)
        try await product.updateWithEnumCast(on: request.db)
        
        return try ProductResponseContent(product: product)
    }
    
    @Sendable
    private func updateProductSold(request: Request) async throws -> ProductResponseContent {
        let id: UUID? = request.parameters.get("id")
        
        guard let product = try await  Product.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        let Content = try request.content.decode(ProductSold.self, using: decoder)
        
        product.setvalue(Content.sold, to: \.sold)
        product.setvalue(Content.salePrice, to: \.salePrice)
        product.setvalue(Content.saleDate, to: \.saleDate)
        try await product.update(on: request.db)
        
        return try ProductResponseContent(product: product)
    }
    
    //MARK: - DELETE
    
    private func deleteProduct(request: Request) async throws -> HTTPStatus {
        let id: UUID? = request.parameters.get("id")
        
        guard let product = try await  Product.find(id, on: request.db) else {
            throw Abort(.notFound)
        }
        
        try await product.delete(force: true, on: request.db)
       
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
    
    func setBrand (_ brandRawValue: String) {
        _ = Brand(rawValue: brandRawValue)
    }
    
    func setSize (_ sizeRawValue: String) {
        _ = Size(rawValue: sizeRawValue)
    }
}
