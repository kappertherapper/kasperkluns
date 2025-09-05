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
}





#Preview {
    AddView()
        .environment(ProductService())
}
