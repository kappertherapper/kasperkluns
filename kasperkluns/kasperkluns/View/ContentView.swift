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
    
    @State private var selectedItem: ProductReponse? = nil
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
                }
                .refreshable {
                    Task {
                        try await productService.fetchProducts()
                    }
                }
            }
            //Button(action: {
            //  selectedItem = product
            //showingDetailSheet = true
            //}) {
            
            //  .navigationTitle("Products")
            //.sheet(isPresented: $showingDetailSheet) {
            //  ProductDetailView(product: product)
        }
    }
}


#Preview {
    ContentView()
}
