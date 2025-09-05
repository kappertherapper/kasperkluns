import SwiftUI

struct ContentView: View {
    
    @Environment(ProductService.self) private var productService
    @State private var selectedItem: ProductReponse? = nil
    
    @State private var gotoDetailView = false
    @State private var showAddView = false
    @State private var showConfirmation = false
    
    @State private var sortOption: String = "All"
    
   
 
    
    var filteredProducts: [ProductReponse] {
        switch sortOption {
        case "Sold":
            return productService.products.filter { $0.sold }
        default:
            return productService.products
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if productService.isLoading {
                    ProgressView("Henter produkter..")
                        .padding()
                } else if productService.products.isEmpty {
                    VStack {
                        Text("No products found")
                            .foregroundColor(.secondary)
                        
                        Button("Refresh") {
                            Task {
                                try await productService.fetchProducts()
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    List(filteredProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            HStack(spacing: 10) {
                                Text(product.sku.formatted())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(product.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 5)
                                
                                    Spacer()
                                
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            selectedItem = product
                                            showConfirmation = true
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                
                            if product.sold  {
                                Text("Sold")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .bold()
                                    .padding(.horizontal, 20)
                            }
                        }
                        
                        }
                        
                    }
                    .alert("You sure u want to delete this product?",
                           isPresented: $showConfirmation,
                           presenting: selectedItem) { product in
                        Button("Cancel", role: .cancel) {}
                        Button("Yes", role: .destructive) {
                            Task {
                                do {
                                    try await productService.deleteProduct(id: product.id)
                                } catch {
                                    print("Fejl ved sletning: \(error)")
                                }
                            }
                        }
                    } message: {_ in
                        Text("It will be gone forever!")
                    }
                    
                    Button(action: {
                        showAddView = true
                    }) {
                        Text("Add product")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(10)
                            .bold()
                    }
                    
                    .navigationTitle("Products")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {
                                Button("All") { sortOption = "All" }
                                Button("Sold") { sortOption = "Sold" }
                            } label: {
                                Label("Vælg", systemImage: "chevron.down")
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                Task {
                                    try await productService.fetchProducts()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                    }
                    .refreshable {
                        Task {
                            try await productService.fetchProducts()
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddView) {
            AddView()
        }
    }
}
    
    #Preview {
        ContentView()
            .environment(ProductService())
    }
