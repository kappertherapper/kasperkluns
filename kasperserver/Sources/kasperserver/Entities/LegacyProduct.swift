import FluentPostgresDriver
import Vapor

struct LegacyProduct: Content {
    let id: Int
    let name: String
    let brand: String?
    let category: String?
    let size: String?
    let condition: String?
    let description: String?
    let purchasePrice: Double?
    let purchaseDate: Date?
    let sellingPrice: Double?
    let saleDate: Date?
    var sold: Bool? = false
}

extension LegacyProduct {
    init(id: Int, name: String, brand: String? = nil) {
        self.id = id
        self.name = name
        self.brand = brand ?? "brand"
        self.category = nil
        self.size = nil
        self.condition = nil
        self.description = nil
        self.purchasePrice = nil
        self.purchaseDate = nil
        self.sellingPrice = nil
        self.saleDate = nil
        self.sold = false
    }
}
