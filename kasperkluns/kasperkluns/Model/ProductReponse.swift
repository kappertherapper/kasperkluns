//
//  Product.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import Foundation

struct ProductReponse: Codable, Identifiable {
    let id: UUID
    var sku: Int
    var name: String
    var description: String? = ""
    var brand: Brand?
    let sold: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
}

extension ProductReponse {
    func toUpdateContent() -> ProductUpdate {
        return ProductUpdate(
            sku: self.sku,
            name: self.name,
            description: self.description ?? "",
            brand: self.brand ?? Brand.NewBalance
        )
    }
}
