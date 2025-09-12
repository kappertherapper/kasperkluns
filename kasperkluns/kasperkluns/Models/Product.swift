import Foundation

struct Product: Identifiable, Codable {
    let id: UUID
    let sku: Int
    let name: String
    var description: String? = ""
    var brand: Brand
    var size: Size
    let purchasePrice: Double
    let salePrice: Double

    var revenue: Double {
        salePrice - purchasePrice
    }
    
    init(from response: ProductReponse) {
        self.id = response.id
        self.sku = response.sku
        self.name = response.name
        self.description = response.description
        self.brand = response.brand
        self.size = response.size
        self.purchasePrice = response.purchasePrice
        self.salePrice = response.salePrice ?? 0.0
        }
    
    func spacedText(_ text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1 $2")
    }
}

// MARK: - ENUMS

enum Brand: String, Codable, CaseIterable, Identifiable {
    case NewBalance = "NewBalance"
    case Nike = "Nike"
    case Salomon = "Salomon"
    case adidas = "adidas"
    case Asics = "Asics"
    case Hoka = "Hoka"
    case Merrell = "Merrell"
    case unknown = "unknown"
    
    var id: String { self.rawValue }
}

enum Size: String, Codable, CaseIterable, Identifiable {
    // Shoe sizes
    case size36   = "36"
    case size36_5 = "36.5"
    case size37   = "37"
    case size37_5 = "37.5"
    case size38   = "38"
    case size38_5 = "38.5"
    case size39   = "39"
    case size39_5 = "39.5"
    case size40   = "40"
    case size40_5 = "40.5"
    case size41   = "41"
    case size41_5 = "41.5"
    case size42   = "42"
    case size42_5 = "42.5"
    case size43   = "43"
    case size43_5 = "43.5"
    case size44   = "44"
    case size44_5 = "44.5"
    case size45   = "45"
    case size45_5 = "45.5"
    case size46   = "46"
    case size46_5 = "46.5"
    case size47   = "47"
    case size47_5 = "47.5"
    case size48   = "48"
    case size48_5 = "48.5"
    case size49   = "49"
    case size49_5 = "49.5"
    case size50   = "50"

    // Clothing sizes
    case XS
    case S
    case M
    case L
    case XL
    case XXL
    
    var id: String { self.rawValue }
}




