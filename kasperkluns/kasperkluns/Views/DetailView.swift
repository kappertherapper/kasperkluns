import SwiftUI

struct DetailView: View {
    
    // MARK: - parameters
    @Environment(ProductService.self) private var productService
    
    var product: ProductReponse
    @State private var showConfirmation = false
    @State private var showingSheet = false
    @State private var sold = false

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 20) {
                Text(product.name)
                    .font(.title)
                    .bold()
                
                Text("SKU: \(product.sku)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                if let description = product.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                } else {
                    Text("Ingen beskrivelse")
                        .italic()
                        .foregroundColor(.gray)
                }
                
                if let brand = product.brand {
                    Text("Brand: \(brand)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Brand ikke angivet")
                        .italic()
                        .foregroundColor(.gray)
                }
            }
            .multilineTextAlignment(.center)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        HStack {
            Button(action: {
                showConfirmation = true
            }) {
                Text("Sold")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(25)
                    .background(product.sold ? Color.green : Color.red)
                    .cornerRadius(10)
                    .bold()
                    .padding(20)
            }
            .disabled(product.sold)
            .alert("Is this product sold boss?", isPresented: $showConfirmation) {
                Button("Yes", role: .destructive, action: markProductSold)
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure?")
            }
            
            Spacer()
            
            Button(action: {
                showingSheet = true
            }) {
                Text("Edit")
                    .font(.title)
                    .foregroundColor(.white)
                    .padding(25)
                    .foregroundColor(.white)
                    .background(Color.purple)
                    .cornerRadius(10)
                    .bold()
                    .padding(25)
            }
            .sheet(isPresented: $showingSheet) {
                EditView(product: product)
            }
        }
    }
    
    func markProductSold() {
        Task {
            do {
                try await productService.updateProductSold(id: product.id, newSold: true)
            } catch {
                print("Error saving product: \(error)")
            }
        }
    }
}



#Preview {
    
    @Previewable @State var dummyProduct = ProductReponse(
        id: UUID(),
        sku: 123456,
        name: "Test Product",
        description: "This is a test description for the product.",
        brand: Brand(rawValue: "Test Brand"),
        sold: false,
        createdAt: Date(),
        updatedAt: Date(),
        deletedAt: nil
    )
    
    DetailView(product: dummyProduct)
        .environment(ProductService())
}
