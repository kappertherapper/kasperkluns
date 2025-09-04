//
//  ProductDetailView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct ProductDetailView: View {
    
    // MARK: - parameters
    var product: ProductReponse
    @State private var showConfirmation = false
    @State private var showingSheet = false

    var body: some View {
        VStack(spacing: 20) {
            Text(product.description ?? "muuh")
                .font(.largeTitle)
                .padding(.top)
        }
        
        Spacer()
        
        HStack {
            Button(action: {
                showConfirmation = true
            }) {
                Text("Sold")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .alert("Is this product sold boss?", isPresented: $showConfirmation) {
                Button("Yes", role: .destructive) {
                    //product.sold = true //ret sold
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure?")
            }
            
            Spacer()
            
            Button(action: {
                showingSheet = true
            }) {
                Text("Edit")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .sheet(isPresented: $showingSheet) {
                EditView(product: product)
            }
        }
    }
}

#Preview {
    
    @Previewable @State var dummyProduct = ProductReponse(
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
    
    ProductDetailView(product: dummyProduct)
}
