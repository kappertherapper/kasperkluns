//
//  ProductUpdate.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 04/09/2025.
//

struct ProductUpdate: Codable {
    let sku: Int
    var name: String
    var description: String
    var brand: Brand
}
