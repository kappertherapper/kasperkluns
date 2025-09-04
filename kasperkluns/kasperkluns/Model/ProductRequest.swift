import Foundation

struct ProductRequest: Codable {
    var name: String
    let sku: Int
    let description: String?
    let brand: String?
    let sold: Bool?
    let createdAt: Date?
}

