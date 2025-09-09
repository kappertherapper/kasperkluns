import Foundation

struct Product: Identifiable, Codable {
    let id: UUID
    let sku: Int
    let name: String
    var description: String? = ""
    var brand: Brand?
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
        self.brand = response.brand ?? Brand.NewBalance
        self.purchasePrice = response.purchasePrice
        self.salePrice = response.salePrice ?? 0.0
        }
    }

enum Brand: String, Codable, CaseIterable, Identifiable {
    case NewBalance = "NewBalance"
    case Nike = "Nike"
    case Salomon = "Salomon"
    case adidas = "adidas"
    case Asics = "Asics"
    
    var id: String { self.rawValue }
}
