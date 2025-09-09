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
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    if productService.isLoading {
                        ProgressView("Henter produkter..")
                            .padding()
                    } else if productService.products.isEmpty {
                        VStack(spacing: 10) {
                            Text("No products found")
                                .foregroundColor(.secondary)
                            
                            Button("Refresh") {
                                Task {
                                    try await productService.fetchProducts()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                    } else {
                        // List
                        List(filteredProducts) { product in
                            NavigationLink(destination: DetailView(product: product)) {
                                HStack(spacing: 10) {
                                    Text(product.sku.formatted())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text(product.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 5)
                                    
                                    Spacer()
                                    
                                    if product.sold  {
                                        Text("Sold")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                            .bold()
                                            .padding(.horizontal, 20)
                                    }
                                }
                            }
                            .swipeActions {
                                Button(role: .destructive) {
                                    selectedItem = product
                                    showConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            
                        }
                        .listStyle(.plain)
                        
                        // Add button
                        Button(action: {
                            showAddView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Product")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        .alert("Sure you want to delete this product?",
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
                    }
                    
                    Spacer()
                }
            }
            .task {
                do {
                    try await productService.fetchProducts()
                } catch {
                    print("error fetching products: \(error)")
                }
            }
            .refreshable {
                Task {
                    try await productService.fetchProducts()
                }
                
            }
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
            .navigationTitle("Products")
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
