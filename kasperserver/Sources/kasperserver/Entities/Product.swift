import Fluent
import Foundation

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
    var brand: Brand?
    
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

enum Brand: String, Codable {
    case NewBalance
    case Nike
    case Salomon
    case adidas
    case Asics
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
