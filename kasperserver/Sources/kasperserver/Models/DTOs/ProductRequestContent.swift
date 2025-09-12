import Vapor

struct ProductRequestContent: Content {
    var name: String
    let sku: Int
    let description: String?
    let brand: String
    let size: String
    let purchasePrice: Double
    let purchaseDate: Date
    let salePrice: Double?
    let saleDate: Date?
    let sold: Bool?
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
        self.brand = Self.getBrand(requestContent.brand)
        self.size = Self.getSize(requestContent.size)
        self.purchasePrice = requestContent.purchasePrice
        self.purchaseDate = requestContent.purchaseDate
        self.salePrice = requestContent.salePrice
        self.saleDate = requestContent.saleDate
        self.sold = requestContent.sold ?? false
    }
    
    private static func getBrand(_ brand: String) -> Brand {
        return Brand(rawValue: brand) ?? .unknown
    }
    
    private static func getSize(_ size: String) -> Size {
        return Size(rawValue: size) ?? .size50
    }
}
