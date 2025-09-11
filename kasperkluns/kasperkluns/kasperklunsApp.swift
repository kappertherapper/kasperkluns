//
//  kasperklunsApp.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

@main
struct kasperklunsApp: App {
    @State private var productService = ProductService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(productService)
        }
    }
}
