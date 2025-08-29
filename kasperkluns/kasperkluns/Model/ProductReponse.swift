//
//  Product.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI
import Foundation

struct ProductReponse: Codable, Identifiable {
    let id: UUID
    let sku: Int
    var name: String
    let description: String?
    let brand: Brand?
    let sold: Bool?
    let createdAt: Date?
    let updatedAt: Date?
    let deletedAt: Date?
}
