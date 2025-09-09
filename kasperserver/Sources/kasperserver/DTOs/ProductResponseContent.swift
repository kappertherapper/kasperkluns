import Vapor

struct ProductResponseContent: Content {
    let id: UUID
    var name: String
    let sku: Int
    let description: String?
    let brand: String?
    let purchasePrice: Double
    let purchaseDate: Date
    let salePrice: Double?
    let saleDate: Date?
    let sold: Bool?
}

// MARK: - Helper

extension ProductResponseContent {
    init(product: Product) throws {
        id = try product.requireID()
        name = product.name
        sku = product.sku
        description = product.description
        brand = product.brand?.rawValue
        purchasePrice = product.purchasePrice
        purchaseDate = product.purchaseDate
        salePrice = product.salePrice
        saleDate = product.saleDate
        sold = product.sold
    }
}
