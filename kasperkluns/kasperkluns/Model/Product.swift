//
//  Product.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var sold: Bool = false
}
