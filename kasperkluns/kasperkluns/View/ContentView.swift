//
//  ContentView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct ContentView: View {
    
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
    
    @State private var productService = ProductService()
    
    @State private var selectedItem: ProductReponse? = nil
    @State private var selectedValue: Int? = nil
    @State private var showingDetailSheet = false
    @State private var showingAddSheet = false
    
    @State private var sortOption: String = "All"
    
    var filteredProducts: [ProductReponse] {
        switch sortOption {
        case "Sold":
            return productService.products.filter { $0.sold ?? false }
        default:
            return productService.products
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
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
                    List(filteredProducts) { product in
                        HStack {
                            Text(product.name)
                                .onTapGesture {
                                    selectedItem = product
                                    showingDetailSheet = true
                                }
                            if product.sold ?? false  {
                                Spacer()
                                Text("Sold")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .bold()
                            }
                        }
                    }
                    .navigationTitle("Products")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button("All") { sortOption = "All" }
                                Button("Sold") { sortOption = "Sold" }
                            } label: {
                                Label("Vælg", systemImage: "chevron.down")
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                Task {
                                    try await productService.fetchProducts()
                                }
                            }) {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            try await productService.fetchProducts()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingDetailSheet) {
            ProductDetailView(product: selectedItem ?? dummyProduct )
        }
    }
}
    
    #Preview {
        ContentView()
    }
