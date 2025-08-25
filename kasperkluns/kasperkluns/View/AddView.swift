//
//  AddView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct AddView: View {
    
    @State var product: Product
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                HStack {
                    Text("Name:")
                        .bold()
                    TextField("Name", text: $product.name)
                }
                .padding(.top, 20)
                HStack {
                    Text("Description:")
                        .bold()
                    TextField("Description", text: $product.description)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit product")
        }
        Button(action: {
            // edit action
        }) {
            Text("Add")
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
                .bold()
                .padding(20)
        }
        .alert("Got it all right?", isPresented: $showConfirmation) {
            Button("Yes", role: .destructive) {
                product.sold = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure")
        }
    }
}

#Preview {
    @Previewable @State var product = Product(name: "NB990", description: "cool")
    AddView(product: product)
}
