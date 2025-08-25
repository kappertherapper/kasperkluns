//
//  ProductDetailView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct ProductDetailView: View {
    
    @State var product: Product
    @State private var showConfirmation = false
    @State private var showingSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(product.description)
                .font(.largeTitle)
                .padding(.top)
        }
        
        Spacer()
        
        HStack {
            Button(action: {
                showConfirmation = true
            }) {
                Text("Sold?")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .alert("Got it boss?", isPresented: $showConfirmation) {
                Button("Yes", role: .destructive) {
                    product.sold = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure")
            }
            
            Spacer()
            
            Button(action: {
                showingSheet = true
            }) {
                Text("Changing")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .sheet(isPresented: $showingSheet) {
                EditView(product: $product)
            }
        }
    }
}

#Preview {
    ProductDetailView(product: Product(name: "NB 990", description: "cool"))
}
