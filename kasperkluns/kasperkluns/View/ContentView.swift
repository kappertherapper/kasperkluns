//
//  ContentView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct ContentView: View {
    
    var products = [
        Product(name: "New Balance 990 v3", description: "fucking seje"),
        Product(name: "New Balance 2002R", description: "slidte øv bøv"),
        Product(name: "New Balance 993", description: "dejlige")
    ]
    
    @State private var selectedItem: Product? = nil
    @State private var showingSheet = false
    
    var body: some View {
        NavigationView {
            List(products) { product in
                Button(action: {
                    selectedItem = product
                    showingSheet = true
                }) {
                    VStack {
                        /*@START_MENU_TOKEN@*/Text(product.name)/*@END_MENU_TOKEN@*/
                    }
                    .navigationTitle("Products")
                    .sheet(isPresented: $showingSheet) {
                        ProductDetailView(product: product)
                    }
                }
            }
        }
        HStack {
            Button(action: {
                
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
        }
    }
}

#Preview {
    ContentView()
}
