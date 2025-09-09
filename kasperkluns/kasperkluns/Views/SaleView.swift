//
//  SaleView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 08/09/2025.
//

import SwiftUI

struct SaleView: View {
    @Environment(ProductService.self) private var productService
    @Environment(\.dismiss) private var dismiss
    
    @State private var salePrice: Double? = nil
    @State private var saleDate: Date = Date()
    var product: ProductReponse
    
    var body: some View {
        VStack {
            Text("\(product.brand?.rawValue ?? "Unknown") \(product.name)")
                .font(.title)
                .bold()
            
            Text("SKU: \(product.sku)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 100)
            
            HStack {
                Text("Sale Price:")
                    .font(.title3)
                Spacer()
                TextField("Sale Price", value: $salePrice, format: .currency(code: "DKK"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .padding(.horizontal, 10)
            }
            .padding(.bottom, 15)
            
            DatePicker("Sale Date:", selection: $saleDate, displayedComponents: .date)
                .font(.title3)
            
            
        }
        .padding()
        
        Button(action: {
            Task {
                do {
                    try await productService.updateProductSold(id: product.id, salePrice: salePrice ?? 0.0, saleDate: saleDate, sold: true)
                } catch {
                    print("Error saving product: \(error)")
                }
            }
            dismiss()
        }) {
            Text("Save Sale")
                .font(.title2)
                .foregroundColor(.white)
                .padding(20)
                .foregroundColor(.white)
                .background(Color.purple)
                .cornerRadius(10)
                .bold()
                .padding(50)
                
        }
    }
}

#Preview {
    
    @Previewable @State var dummyProduct = ProductReponse(
        id: UUID(),
        sku: 123456,
        name: "990 v4",
        description: "This is a test description for the product.",
        brand: Brand.NewBalance,
        purchasePrice: 99.99,
        purchaseDate: Date(),
        salePrice: 100.00,
        saleDate: Date(),
        sold: false,
    )
    
    SaleView(product: dummyProduct)
        .environment(ProductService())
}
