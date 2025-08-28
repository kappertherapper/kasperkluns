import Vapor

struct ProductResponseContent: Content {
    let id: UUID
    var name: String
    let sku: Int
    let description: String?
    let brand: String?
    let sold: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
}

// MARK: - Helper

extension ProductResponseContent {
    init(product: Product) throws {
        id = try product.requireID()
        name = product.name
        sku = product.sku
        description = product.description
        brand = product.brand?.rawValue
        sold = product.sold
        createdAt = product.createdAt
        updatedAt = product.updatedAt
        deletedAt = product.deletedAt
    }
}
