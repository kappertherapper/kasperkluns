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
    
    /*
    var brand: Brand? {
        get {
            guard let _brand = _brand else { return nil }
            return Brand(rawValue: _brand)
        }
        set {
            _brand = newValue?.rawValue
        }
    }
     */
    
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

enum Brand: String, CaseIterable, Codable {
    case NewBalance = "NewBalance"
    case Nike = "Nike"
    case Salomon = "Salomon"
    case adidas = "adidas"
    case Asics = "Asics"
    case Hoka = "Hoka"
    case Merrell = "Merrell"
    case unknown = "unknown"
}

enum Size: String, Codable, CaseIterable {
    // Shoe sizes
    case size36   = "36"
    case size36_5 = "36.5"
    case size37   = "37"
    case size37_5 = "37.5"
    case size38   = "38"
    case size38_5 = "38.5"
    case size39   = "39"
    case size39_5 = "39.5"
    case size40   = "40"
    case size40_5 = "40.5"
    case size41   = "41"
    case size41_5 = "41.5"
    case size42   = "42"
    case size42_5 = "42.5"
    case size43   = "43"
    case size43_5 = "43.5"
    case size44   = "44"
    case size44_5 = "44.5"
    case size45   = "45"
    case size45_5 = "45.5"
    case size46   = "46"
    case size46_5 = "46.5"
    case size47   = "47"
    case size47_5 = "47.5"
    case size48   = "48"
    case size48_5 = "48.5"
    case size49   = "49"
    case size49_5 = "49.5"
    case size50   = "50"

    // Clothing sizes
    case XS
    case S
    case M
    case L
    case XL
    case XXL
}


enum Condition: Int, Codable {
    case ten = 10
    case nine = 9
    case eight = 8
    case seven = 7
    case six = 6
    case five = 5
    case four = 4
    case three = 3
    case two = 2
    case one = 1
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
