import Foundation

struct ProductReponse: Codable, Identifiable {
    let id: UUID
    var sku: Int
    var name: String
    var description: String? = ""
    var brand: Brand?
    var purchasePrice: Double
    var purchaseDate: Date
    var salePrice: Double?
    var saleDate: Date?
    var sold: Bool
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    
    func revenue() -> Double {
        return (salePrice ?? 0.0) - purchasePrice
    }
}



