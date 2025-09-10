//
//  InfoView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 10/09/2025.
//

import SwiftUI

struct InfoView: View {
    @Environment(ProductService.self) private var productService
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    InfoView()
        .environment(ProductService())
}
