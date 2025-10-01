import SwiftUI

struct EditView: View {
    @Environment(ProductService.self) private var productService
    @Environment(\.dismiss) private var dismiss
    @State private var editableProduct: ProductReponse
    var productId: UUID
    
    init(product: ProductReponse) {
        self._editableProduct = State(initialValue: product)
        self.productId = product.id
    }
    
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Edit Product")) {
                // Name
                HStack {
                    Text("Name: ")
                        .bold()
                    TextField("", text: $editableProduct.name)
                }
                .textFieldStyle(.roundedBorder)
                .padding(.top, 10)
                
                // Description
                HStack(alignment: .top) {
                    Text("Description: ")
                        .bold()
                    
                    TextEditor(text: $editableProduct.description.defaultValue(""))
                        .padding(4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .frame(height: 100)
                }
                .padding(.top, 10)
                
                HStack {
                    // Brand
                    HStack {
                        Picker("Brand", selection: $editableProduct.brand) {
                            ForEach(Brand.allCases) { brand in
                                Text(brand.rawValue).tag(brand)
                            }
                        }
                        .labelsHidden()
                        .bold()
                        .pickerStyle(.menu)
                    }
                    
                    Divider()
                        .padding(.horizontal, 25)
                
                    // Size
                    HStack {
                        Picker("Size", selection: $editableProduct.size) {
                            ForEach(Size.allCases) { size in
                                Text(size.rawValue).tag(size)
                            }
                        }
                        .labelsHidden()
                        .bold()
                        .pickerStyle(.menu)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 10)
                
                // Purchase
                HStack {
                    Text("Purchase Price:")
                        .bold()
                    
                    Spacer()
                    
                    TextField("0", value: $editableProduct.purchasePrice, format: .currency(code: "DKK"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 10)
                }
                .padding(5)
                
                DatePicker("Purchase Date:", selection: $editableProduct.purchaseDate, displayedComponents: .date)
                    .bold()
                    .padding(5)
                
                // Sale
                HStack {
                    Text("Sale Price:")
                        .bold()
                        .padding(5)
                    
                    Spacer()
                    
                    TextField("0", value: $editableProduct.salePrice, format: .currency(code: "DKK"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .padding(.horizontal, 10)
                }
                .padding(5)
                
                DatePicker(
                    "Sale Date:",
                    selection: Binding(
                        get: { (editableProduct.saleDate ?? Calendar.current.date(from: Calendar.current.dateComponents([.year], from: Date())))! },
                        set: { editableProduct.saleDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .bold()
                .padding(5)
                
                
                HStack {
                    Toggle("Sold?", isOn: $editableProduct.sold)
                        .bold()
                    Text("\(editableProduct.sold ? "True" : "False")")
                        .font(.caption)
                }
                .padding(5)
            }
            .onChange(of: editableProduct.sold) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    editableProduct.salePrice = nil
                    editableProduct.saleDate = nil
                }
            }
        }
            HStack(spacing: 20) {
                // Cancel button
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
                
                Spacer()
                
                // Save button
                Button(action: {
                    Task {
                        try await productService.editProduct(
                            id: productId,
                            updatedProduct: editableProduct
                        )
                        dismiss()
                    }
                }) {
                    Label("Save", systemImage: "checkmark")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
            }
            .padding(.horizontal)
        }
    }

    


extension Binding where Value == String? {
    func defaultValue(_ default: String) -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? `default` },
            set: { self.wrappedValue = $0 }
        )
    }
}

#Preview {
    @Previewable @State var dummyProduct = ProductReponse(
        id: UUID(),
        sku: 123456,
        name: "990 v4",
        description: "This is a test description for the product.",
        brand: Brand.NewBalance,
        size: Size.size40,
        purchasePrice: 99.99,
        purchaseDate: Date(),
        salePrice: 100.00,
        saleDate: Date(),
        sold: false,
    )
    EditView(product: dummyProduct)
        .environment(ProductService())
}
