import SwiftUI

struct AddPersonalView: View {
    
    @Environment(ProductService.self) private var productService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var sku: Int = 0
    @State private var description: String = ""
    @State private var brand: Brand = .unknown
    @State private var size: Size = .size40
    @State private var sold: Bool = false
    @State private var purchasePrice: Double? = nil
    @State private var purchaseDate: Date = Date()
    @State private var count: Int = 0
    
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Add a new Product")) {
                // Name
                HStack {
                    Text("Name: ").bold()
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                // SKU
                HStack {
                    Text("Sku: ").bold()
                    
                    // Reload btn
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
                        .padding(.leading, 60)
                        .font(.largeTitle)
                        .disabled(true)
                }
                .padding(.top, 10)
                
                // Description
                HStack(alignment: .top) {
                    Text("Description: ").bold()
                    
                    TextEditor(text: $description)
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(height: 100)
                }
                HStack {
                    // Brand
                    HStack {
                        Picker("Brand", selection: $brand) {
                            ForEach(Brand.allCases) { brand in
                                Text(brand.rawValue).tag(brand)
                            }
                        }
                        .labelsHidden()
                        .bold()
                        .pickerStyle(.menu)
                    }
                    .frame(maxWidth: .infinity)
                    
                    
                    Divider()
                        .padding(.horizontal, 25)
                        
                    // Size
                    HStack {
                        Picker("Size", selection: $size) {
                            ForEach(Size.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .labelsHidden()
                        .bold()
                        .pickerStyle(.menu)
                        .padding(.trailing, 15)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)

                // Purchase
                HStack {
                    Text("Purchase Price:").bold()
                        .padding(.bottom, 10)
                        
                    
                    Spacer()
                    
                    TextField("0", value: $purchasePrice, format: .currency(code: "DKK"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 15)
                }
                
                
                DatePicker("Purchase Date:", selection: $purchaseDate, displayedComponents: .date)
                    .bold()
            }
            .padding(.top, 10)
        }
        HStack(spacing: 20) {
            // Cancel Btn
            Button(action: {
                dismiss()
            }) {
                Label("Cancel", systemImage: "xmark")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            
            // Add Btn
            Button(action: {
                Task {
                    try await productService.addProduct(
                        name: name,
                        Sku: sku,
                        description: description,
                        brand: brand.rawValue,
                        size: size.rawValue,
                        purchasePrice: purchasePrice ?? 0.0,
                        purchaseDate: purchaseDate,
                        sold: sold
                    )
                }
                dismiss()
            }) {
                Label("Add", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .disabled(sku == 0)
        }
        .padding(.horizontal, 20)
        .onAppear {
            Task {
                count = await productService.getProductCount()
                sku = count
            }
        }
    }
}

#Preview {
    AddPersonalView()
        .environment(ProductService())
}
