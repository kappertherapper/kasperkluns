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
    
    @OptionalField(key: "brand")
        private var _brand: String?
        
    var brand: Brand? {
        get {
            guard let _brand = _brand else { return nil }
            return Brand(rawValue: _brand)
        }
        set {
            _brand = newValue?.rawValue
        }
    }
    
    @Boolean(key: "sold")
    var sold: Bool
    
    @Timestamp(key: "createdAt", on: .create)
    var createdAt: Date?
    
    @Timestamp(key: "updatedAt", on: .update)
    var updatedAt: Date?
    
    @Timestamp(key: "deletedAt", on: .delete)
    var deletedAt: Date?
    
    init() {}
}

enum Brand: String, CaseIterable, Codable {
    case NewBalance = "NewBalance"
    case Nike = "Nike"
    case Salomon = "Salomon"
    case adidas = "adidas"
    case Asics = "Asics"
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
                INSERT INTO products (id, sku, name, description, brand, sold, "createdAt", "updatedAt") 
                VALUES (gen_random_uuid(), \(bind: self.sku), \(bind: self.name), \(bind: self.description), \(bind: self._brand ?? Brand.NewBalance.rawValue)::brand, \(self.sold), \(bind: self.createdAt), \(bind: self.updatedAt))
                RETURNING id, "createdAt", "updatedAt"
                """).first()
            
            if let row = result {
                self.id = try row.decode(column: "id", as: UUID.self)
                //self.createdAt = try row.decode(column: "createdAt", as: Date.self)
                //self.updatedAt = try row.decode(column: "updatedAt", as: Date.self)
            }
        }
    }
}
