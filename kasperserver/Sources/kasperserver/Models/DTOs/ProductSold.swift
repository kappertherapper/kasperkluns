import Vapor

struct ProductSold: Content {
    let sold: Bool
    let salePrice: Double?
    let saleDate: Date?
}
