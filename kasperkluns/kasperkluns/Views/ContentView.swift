import SwiftUI

struct ContentView: View {
    
    @Environment(ProductService.self) private var productService
    @State private var selectedItem: ProductReponse? = nil
    
    @State private var gotoDetailView = false
    @State private var showAddView = false
    @State private var showConfirmation = false
    
    @State private var sortOption: String = "All"
    @State private var searchText = ""
    
    
    
    
    var filteredProducts: [ProductReponse] {
        var products = productService.products
        
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
        let endOfMonth = calendar.date(byAdding: .second, value: -1, to: startOfNextMonth)!
        //let endofNextMonth = calendar.date(byAdding: .month, value: 1, to: endOfMonth)!
        
        
        switch sortOption {
        case "Sold": return products.filter { $0.sold }
        case "Not Sold": return products.filter { !$0.sold }
        case "This Month": return products.filter {
                guard let saleDate = $0.saleDate else { return false }
                return saleDate >= startOfMonth && saleDate <= endOfMonth
            }
        default:
            break
        }
        
        if !searchText.isEmpty {
            products = products.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.brand.rawValue.localizedCaseInsensitiveContains(searchText) == true ||
                String(product.sku).contains(searchText)
            }
        }
        
        if sortOption == "Price Low-High" {
            products = products.sorted { $0.purchasePrice < $1.purchasePrice }
        } else if sortOption == "Price High-Low" {
            products = products.sorted { $0.purchasePrice > $1.purchasePrice }
        }
        
        return products.sorted { $0.sku < $1.sku }
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
                        List(filteredProducts, id: \.id) { product in
                            NavigationLink(destination: DetailView(product: product)) {
                                HStack(spacing: 20) {
                                    Text(product.sku.formatted())
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    HStack {
                                        Text("\(spacedText(product.brand.rawValue)) \(product.name)")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .padding(.vertical, 5)
                                    }
                                    
                                    
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
                        Button("Not Sold") { sortOption = "Not Sold" }
                        Button("Price Low-High") { sortOption = "Price Low-High" }
                        Button("Price High-Low") { sortOption = "Price High-Low" }
                    } label: {
                        Label("Vælg", systemImage: "chevron.down")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("This Month") { sortOption = "This Month" }
                    } label: {
                        Label("Vælg", systemImage: "calendar.badge.clock")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Products..")
            .navigationTitle("Products")
        }
        .sheet(isPresented: $showAddView) {
            AddView()
                .onDisappear() {
                    Task {
                        try await productService.fetchProducts()
                    }
                }
        }
    }
}
    
    #Preview {
        ContentView()
            .environment(ProductService())
    }
