//
//  ContentView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct ContentView: View {
    
    //var products = [
    //Product(name: "New Balance 990 v3", description: "fucking seje"),
    //Product(name: "New Balance 2002R", description: "slidte øv bøv", sold: true),
    //Product(name: "New Balance 993", description: "dejlige")
    
    @State private var productService = ProductService()
    
    @State var selectedItem: ProductReponse
    @State private var showingDetailSheet = false
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            if productService.isLoading {
                ProgressView("Henter produkter..")
                    .padding()
            } else if productService.products.isEmpty {
                VStack {
                    Text("No products found")
                        .foregroundColor(.secondary)
                    
                    Button("Refresh") {
                        Task {
                            try await productService.fetchProducts()
                        }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                List(productService.products) { product in
                    Text(product.name)
                    
                    Button(action: {
                        selectedItem = product
                        showingDetailSheet = true
                    }) {
                        
                    }
                }
                .refreshable {
                    Task {
                        try await productService.fetchProducts()
                    }
                }
            }
        }
        .navigationTitle("Products")
        .sheet(isPresented: $showingDetailSheet) {
            ProductDetailView(product: selectedItem )
        }
    }
}
    
    #Preview {
        let dummyProduct = ProductReponse(
            id: UUID(),
            sku: 123456,
            name: "Test Product",
            description: "This is a test description for the product.",
            brand: Brand(rawValue: "Test Brand"),
            sold: false,
            createdAt: Date(),
            updatedAt: Date(),
            deletedAt: nil
        )
        ContentView(selectedItem: dummyProduct)
    }
