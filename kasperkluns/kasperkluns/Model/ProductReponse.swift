import Foundation

struct ProductReponse: Codable, Identifiable {
    let id: UUID
    var sku: Int
    var name: String
    var description: String? = ""
    var brand: Brand?
    var sold: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
}
