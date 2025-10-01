import Vapor

struct ProductRequestContent: Content {
    var name: String
    let sku: Int
    let description: String?
    let brand: Brand
    let size: Size
    let purchasePrice: Double
    let purchaseDate: Date
}

// MARK: - Helper

extension Product {
    convenience init(
        requestContent: ProductRequestContent,
        name: String,
        sku: Int
    ) {
        self.init()
        self.name = name
        self.sku = sku
        self.description = requestContent.description
        self.brand = requestContent.brand
        self.size = requestContent.size
        self.purchasePrice = requestContent.purchasePrice
        self.purchaseDate = requestContent.purchaseDate
    }
}
