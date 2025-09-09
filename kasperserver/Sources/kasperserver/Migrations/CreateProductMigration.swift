import Fluent

struct CreateProductMigration: AsyncMigration {
    func prepare(on database: any Database) async throws {
        let brand = try await database.enum("brand")
            .case(Brand.NewBalance.rawValue)
            .case(Brand.Nike.rawValue)
            .case(Brand.Salomon.rawValue)
            .case(Brand.adidas.rawValue)
            .case(Brand.Asics.rawValue)
            .create()
        
        try await database.schema(Product.schema)
            .id()
            .field("name", .string, .required)
            .field("sku", .int, .required)
            .unique(on: "sku")
            .field("description", .string)
            .field("brand", brand)
            .field("purchase_price", .double, .required)
            .field("purchase_date", .date, .required)
            .field("sale_price", .double)
            .field("sale_date", .date)
            .field("sold", .bool, .required, .sql(.default(false)))
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .field("deleted_at", .datetime)
            .create()
    }
    
    func revert(on database: any Database) async throws {
        try await database.schema(Product.schema).delete()
        try await database.enum("brand").delete()
    }
}
