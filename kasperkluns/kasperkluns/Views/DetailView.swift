import SwiftUI

struct DetailView: View {
    
    // MARK: - parameters
    @Environment(ProductService.self) private var productService
    
    var product: ProductReponse
    @State private var showConfirmation = false
    @State private var showingSheet = false
    @State private var showingSoldSheet = false
    @State private var sold = false
    
    var body: some View {
        VStack {
            Text("Product Details").font(.title).fontWeight(.bold)
            
            Spacer()

            VStack(spacing: 20) {
                // Product Info Card
                VStack(spacing: 8) {
                    HStack {
                        if let brand = product.brand {
                            Text(spacedText(brand.rawValue)).font(.title).bold()
                        } else {
                            Text("Brand not set").bold()
                        }
                        Text(product.name).font(.title).bold()
                    }
                    
                    Text("SKU: \(product.sku)").font(.subheadline).foregroundColor(.gray)
                    Text(product.description?.isEmpty == false ? product.description! : "No description")
                        .italic(product.description?.isEmpty ?? true)
                        .foregroundColor(product.description?.isEmpty == false ? .primary : .gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 2)
                .frame(maxWidth: 400)

                // Purchase Info Card
                VStack(spacing: 10) {
                    Text("Purchase Info").font(.headline)
                    HStack {
                        Text("Price: \(product.purchasePrice, specifier: "%.2f")")
                        Spacer()
                        Text("Date: \(product.purchaseDate.formatted(date: .abbreviated, time: .omitted))")
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.15))
                .cornerRadius(12)
                .frame(maxWidth: 400)

                // Sale Info Card
                VStack(spacing: 10) {
                    Text("Sale Info").font(.headline)
                    HStack {
                        if let price = product.salePrice {
                            Text("Price: \(price, specifier: "%.2f")")
                        } else {
                            Text("Sale Price not set").italic().foregroundColor(.gray)
                        }
                        Spacer()
                        if let date = product.saleDate {
                            Text("Date: \(date.formatted(date: .abbreviated, time: .omitted))")
                        } else {
                            Text("Sale Date not set").italic().foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)
                .frame(maxWidth: 400)
                
                // Revenue Info Card
                VStack(spacing: 10) {
                    Text("Revenue").font(.headline)
                    HStack {
                        Text("Profit: \(product.revenue(), specifier: "%.2f") kr")
                            .italic().foregroundColor(.gray)
                    }
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.yellow.opacity(0.15))
                .cornerRadius(12)
                .frame(maxWidth: 400)
                
            }
            .padding()
            Spacer() // fylder bunden og centrerer alt lodret
        
            
            
            // Buttons
            HStack(spacing: 20) {
                Button(action: {
                    showConfirmation = true
                }) {
                    Label("Sold", systemImage: product.sold ? "checkmark.circle.fill" : "cart.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(product.sold ? Color.green : Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .disabled(product.sold)
                .alert("Is this product sold boss?", isPresented: $showConfirmation) {
                    Button("Yes", role: .destructive, action: { showingSoldSheet = true })
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("Are you sure?")
                }
                
                Button(action: {
                    showingSheet = true
                }) {
                    Label("Edit", systemImage: "pencil")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                }
                .sheet(isPresented: $showingSheet) { EditView(product: product) }
                .sheet(isPresented: $showingSoldSheet) { SaleView(product: product) }
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
        
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
    
func spacedText(_ text: String) -> String {
        let regex = try! NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "$1 $2")
    }



#Preview {
    
    @Previewable @State var dummyProduct = ProductReponse(
        id: UUID(),
        sku: 123456,
        name: "990 v4",
        description: "This is a test description for the product.",
        brand: Brand.NewBalance,
        purchasePrice: 99.99,
        purchaseDate: Date(),
        salePrice: 100.00,
        saleDate: Date(),
        sold: false,
    )
    
    DetailView(product: dummyProduct)
        .environment(ProductService())
}
