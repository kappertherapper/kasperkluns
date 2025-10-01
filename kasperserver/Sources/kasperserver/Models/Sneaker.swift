import Fluent
import Vapor
import Foundation
import PostgresKit

final class Sneaker: Model, @unchecked Sendable {
    static let schema = "products"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @OptionalField(key: "description")
    var description: String?
    
    @Field(key: "brand")
    var brand: Brand
    
    @Field(key: "size")
    var size: Size
    
    @OptionalField(key: "image")
    var image: Data?
    
    @OptionalField(key: "purchase_price")
    var purchasePrice: Double?
    
    @OptionalField(key: "purchase_date")
    var purchaseDate: Date?
    
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

