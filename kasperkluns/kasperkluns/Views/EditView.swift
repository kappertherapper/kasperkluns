import SwiftUI

struct EditView: View {
    @Environment(ProductService.self) private var productService
    @State private var editableProduct: ProductReponse
    var productId: UUID
    
    init(product: ProductReponse) {
        self._editableProduct = State(initialValue: product)
        self.productId = product.id
    }
    
    @State private var showConfirmation = false
    
    var body: some View {
        Form {
            HStack {
                Text("Name: ")
                    .bold()
                TextField("", text: $editableProduct.name)
            }
            .textFieldStyle(.roundedBorder)
            .padding(.top, 10)
            
            HStack(alignment: .top) {
                Text("Description: ")
                    .bold()
                
                TextEditor(text: $editableProduct.description.defaultValue(""))
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .frame(height: 100)
            }
            .padding(.top, 20)
            
            HStack {
                Picker("Brand", selection: $editableProduct.brand) {
                    ForEach(Brand.allCases) { brand in
                        Text(brand.rawValue).tag(brand)
                    }
                }
                .bold()
                .pickerStyle(.menu)
            }
            .padding(.top, 20)
            
            
            HStack {
                Toggle("Sold?", isOn: $editableProduct.sold)
                    .bold()
                Text("\(editableProduct.sold ? "True" : "False")")
                    .font(.caption)
            }
            .padding(.top, 20)
            
            HStack {
                Spacer()
                Button(action: {
                    showConfirmation.toggle()
                }) {
                    Text("Save")
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
                            try await productService.editProduct(
                                id: productId,
                                updatedProduct: editableProduct,
                            )
                        }
                    }
                } message: {
                    Text("Are you sure")
                }
            }
        }
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
        name: "Test Product",
        description: "This is a test description for the product.",
        brand: Brand(rawValue: "Test Brand"),
        purchasePrice: 99.99,
        purchaseDate: Date(),
        salePrice: 100.00,
        saleDate: Date(),
        sold: false,
    )
    EditView(product: dummyProduct)
        .environment(ProductService())
}

