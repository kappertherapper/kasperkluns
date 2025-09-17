import Foundation

struct ProductReponse: Codable, Identifiable {
    let id: UUID
    var sku: Int
    var name: String
    var description: String? = ""
    var brand: Brand
    var size: Size
    var purchasePrice: Double
    var purchaseDate: Date
    var salePrice: Double?
    var saleDate: Date?
    var sold: Bool
    
    func revenue() -> Double {
        let value = (salePrice ?? 0.0) - purchasePrice
        return (value * 100).rounded() / 100
    }
}



