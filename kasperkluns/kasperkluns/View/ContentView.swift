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
        Product(name: "New Balance 2002R", description: "slidte øv bøv", sold: true),
        Product(name: "New Balance 993", description: "dejlige")
    ]
    
    @State private var selectedItem: Product? = nil
    @State private var showingDetailSheet = false
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationView {
            List(products) { product in
                Button(action: {
                    selectedItem = product
                    showingDetailSheet = true
                }) {
                    HStack {
                        //Text(product.id.uuidString)
                        /*@START_MENU_TOKEN@*/Text(product.name)/*@END_MENU_TOKEN@*/
                        
                        Spacer()
                        
                        Circle()
                            .fill(product.sold ? Color.green : Color.red)
                            .frame(width: 20, height: 15)
                            .shadow(radius: 5)
                    }
                    .navigationTitle("Products")
                    .sheet(isPresented: $showingDetailSheet) {
                        ProductDetailView(product: product)
                    }
                }
            }
        }
        HStack {
            Button(action: {
                showingAddSheet = true
            }) {
                Text("Add")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddView()
            }
        }
    }
}

#Preview {
    ContentView()
}
