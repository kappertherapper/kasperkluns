//
//  EditView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct EditView: View {
    
    @Binding var product: ProductReponse
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                HStack {
                    Text("Name:")
                        .bold()
                    //TextField("Name", text: $product.name)
                }
                .padding(.top, 20)
                HStack {
                    Text("Description:")
                        .bold()
                    //TextField("Description", text: $product.description)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit product")
        }
        Button(action: {
            // edit action
        }) {
            Text("submit")
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
                .bold()
                .padding(20)
        }
    }
}

#Preview {
    //@Previewable @State var product = Product(name: "NB990", description: "cool")
    //EditView(product: $product)
}
