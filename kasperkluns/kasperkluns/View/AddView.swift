//
//  AddView.swift
//  kasperkluns
//
//  Created by Kasper Jonassen on 25/08/2025.
//

import SwiftUI

struct AddView: View {
    
    @Environment(ProductService.self) private var productService
    
    @State private var name: String = ""
    @State private var sku: Int = 0
    @State private var description: String = ""
    @State private var brand: Brand = .NewBalance
    @State private var sold: Bool = false
    
    @State private var showConfirmation = false
    
    var body: some View {
        ZStack {
            Color.clear.edgesIgnoringSafeArea(.all)
            
            Form {
                Section(header: Text("Add a new Product")) {
                    HStack {
                        Text("Name: ")
                            .bold()
                        TextField("", text: $name)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.top, 10)
                    
                    HStack {
                        Text("Sku: ")
                            .bold()
                        Button(action: {
                            Task {
                                let count = await getProductCount()
                                sku = count
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .bold()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.blue)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 20 )
                        TextField("SKU", value: $sku, format: .number)
                            .padding(.leading, 50)
                            .font(.largeTitle)
                            .disabled(true)
                    }
                    .padding(.top, 20)
                    
                    HStack(alignment: .top) {
                        Text("Description: ")
                            .bold()
                        
                        TextEditor(text: $description)
                            .padding(4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .frame(height: 100)
                    }
                    .padding(.top, 20)
                    
                    HStack {
                        Picker("Brand", selection: $brand) {
                            ForEach(Brand.allCases) { brand in
                                Text(brand.rawValue).tag(brand)
                            }
                        }
                        .bold()
                        .pickerStyle(.menu)
                    }
                    .padding(.top, 20)
                    
                    /*
                    HStack {
                        Toggle("Sold?", isOn: $sold)
                            .bold()
                        //Text("Selected: \(sold ? "True" : "False")")
                    }
                    .padding(.top, 20)
                     */
                }
                HStack {
                    Spacer()
                    Button(action: {
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
                        Button("Yes", role: .destructive) {
                            Task {
                                try await productService.addProduct(
                                    name: name,
                                    Sku: sku,
                                    description: description,
                                    brand: brand.rawValue,
                                    sold: sold)
                            }
                        }
                    } message: {
                        Text("Are you sure")
                    }
                }
            }
        }
    }
    
    func getProductCount() async -> Int {
        do {
            try await productService.fetchProducts()
            return productService.products.count+1
        } catch {
            print("Fejl: \(error)")
            return 0
        }
    }
}





#Preview {
    //@Previewable @State var product = Product(name: "NB990", sku: "55")
    AddView()
        .environment(ProductService())
}
