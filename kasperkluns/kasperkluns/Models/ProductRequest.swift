import Foundation

struct ProductRequest: Codable {
    var name: String
    let sku: Int
    let description: String?
    let brand: String?
    let purchasePrice: Double
    let purchaseDate: Date
    let sold: Bool?
    let createdAt: Date?
}

