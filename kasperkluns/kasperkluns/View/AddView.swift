//
//  AddView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct AddView: View {
    
    @State private var name: String = ""
    @State private var description: String = ""
    
    //var onSave: (Product) -> Void
    
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                HStack {
                    Text("Name: ")
                        .bold()
                    TextField("", text: $name)
                }
                .padding(.top, 20)
                HStack {
                    Text("Description: ")
                        .bold()
                    TextEditor(text: $description)
                }
                .padding(.top, 20)
            }
            .navigationTitle("Edit product")
        }
        Button(action: {
            //_ = Product(name: name, description: description)
            showConfirmation.toggle()
        }) {
            Text("Add")
                .foregroundColor(.white)
                .padding()
                .background(Color.purple)
                .cornerRadius(10)
                .bold()
        }
        .alert("Got it all right?", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Yes", role: .destructive) {}
        } message: {
            Text("Are you sure")
        }
    }
}

#Preview {
    //@Previewable @State var product = Product(name: "NB990", sku: "55")
    AddView()
}
