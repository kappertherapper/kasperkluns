import SwiftUI

struct AddView: View {
    
    @Environment(ProductService.self) private var productService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var sku: Int = 0
    @State private var description: String = ""
    @State private var brand: Brand = .NewBalance
    @State private var sold: Bool = false
    @State private var purchasePrice: Double? = nil
    @State private var purchaseDate: Date = Date()
    
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Add a new Product")) {
                // Name
                HStack {
                    Text("Name: ")
                        .bold()
                    TextField("", text: $name)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.top, 10)
                
                // SKU
                HStack {
                    Text("Sku: ")
                        .bold()
                    Button(action: {
                        Task {
                            let count = await productService.getProductCount()
                            sku = count
                        }
                    }) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .bold()
                            .frame(width: 30, height: 24)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    
                    TextField("SKU", value: $sku, format: .number)
                        .padding(.leading, 50)
                        .font(.largeTitle)
                        .disabled(true)
                }
                .padding(.top, 20)
                
                // Description
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
                
                // Brand
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
                .padding(.bottom, 20)
                
                // Purchase
                HStack {
                    Text("Purchase Price:")
                        .bold()
                    Spacer()
                    TextField("0", value: $purchasePrice, format: .currency(code: "DKK"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 10)
                }
                .padding(.top, 15)
                .padding(.bottom, 15)
                
                DatePicker("Purchase Date:", selection: $purchaseDate, displayedComponents: .date)
                    .bold()
                    .padding(.top, 15)
                    .padding(.bottom, 15)
            }
            
            // Add btn
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
                                purchasePrice: purchasePrice ?? 0.0,
                                purchaseDate: purchaseDate,
                                sold: sold)
                        }
                        dismiss()
                    }
                } message: {
                    Text("Are you sure")
                }
            }
        }
    }
}






#Preview {
    AddView()
        .environment(ProductService())
}
