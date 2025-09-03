import Vapor

struct ProductRequestContent: Content {
    var name: String
    let sku: Int
    let description: String?
    let brand: String?
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
        self.sold = requestContent.sold ?? false
    }
    
    private static func getBrand(_ brand: String?) -> Brand? {
        guard let brand else { return nil }
        
        //print("Converting brand string: '\(brand)'") //Test
        return Brand(rawValue: brand)
    }
}
