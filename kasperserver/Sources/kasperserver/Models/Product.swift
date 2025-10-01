import Fluent
import Vapor
import Foundation
import PostgresKit

final class Product: Model, @unchecked Sendable {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "sku")
    var sku: Int
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "brand")
    var brand: Brand
    
    @Field(key: "size")
    var size: Size
    
    @Field(key: "purchase_price")
    var purchasePrice: Double
    
    @Field(key: "purchase_date")
    var purchaseDate: Date
    
    @OptionalField(key: "sale_price")
    var salePrice: Double?
    
    @OptionalField(key: "sale_date")
    var saleDate: Date?
    
    @Boolean(key: "sold")
    var sold: Bool
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    
    init() {}
}

extension Product {
    func saveWithEnumCast(on database: any Database) async throws {
        guard let sqlDB = database as? (any SQLDatabase) else {
            throw Abort(.internalServerError, reason: "Database is not SQL")
        }
        if self.id == nil {
            let result = try await sqlDB.raw("""
                INSERT INTO products (id, sku, name, description, brand, size, purchase_price, purchase_date, sale_price, sale_date, sold, created_at, updated_at
                ) 
                VALUES (
                gen_random_uuid(),
                \(bind: self.sku),
                \(bind: self.name),
                \(bind: self.description),
                \(bind: self.brand)::brand,
                \(bind: self.size)::size,
                \(bind: self.purchasePrice),
                \(bind: self.purchaseDate),
                \(bind: self.salePrice),
                \(bind: self.saleDate),
                \(self.sold),
                \(bind: self.createdAt ?? Date()),
                \(bind: self.updatedAt ?? Date())
                )
                RETURNING id, "created_at", "updated_at"
                """).first()
            
            if let row = result {
                self.id = try row.decode(column: "id", as: UUID.self)
                self.createdAt = try row.decode(column: "created_at", as: Date.self)
                self.updatedAt = try row.decode(column: "updated_at", as: Date.self)
            }
        }
    }
    
    func updateWithEnumCast(on database: any Database) async throws {
        guard let sqlDB = database as? (any SQLDatabase) else {
            throw Abort(.internalServerError, reason: "Database is not SQL")
        }
        guard let id = self.id else {
            throw Abort(.badRequest, reason: "Cannot update a Product without an ID")
        }
        let result = try await sqlDB.raw("""
                UPDATE products
                SET sku = \(bind: self.sku),
                    name = \(bind: self.name),
                    description = \(bind: self.description),
                    brand = \(bind: self.brand)::brand,
                    size = \(bind: self.size)::size,
                    purchase_price = \(bind: self.purchasePrice),
                    purchase_date = \(bind: self.purchaseDate),
                    sale_price = \(bind: self.salePrice),
                    sale_date = \(bind: self.saleDate),
                    sold = \(self.sold),
                    "updated_at" =  NOW()
                WHERE id = \(bind: id)
                RETURNING id, "updated_at"
            """).first()
        
        if let row = result {
            self.id = try row.decode(column: "id", as: UUID.self)
            self.updatedAt = (try? row.decode(column: "updated_at", as: Date.self)) ?? Date.now
        } else {
            throw Abort(.internalServerError, reason: "Failed to update product or retrieve updatedAt")
        }
    }
}
