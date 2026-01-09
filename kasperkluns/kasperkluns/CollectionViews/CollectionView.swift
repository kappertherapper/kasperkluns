import SwiftUI

struct CollectionView: View {
    
    @Environment(ProductService.self) private var productService
    @State private var selectedItem: ProductReponse? = nil
    
    @State private var gotoDetailView = false
    @State private var showAddView = false
    @State private var showConfirmation = false
    
    @State private var sortOption: String = ""
    @State private var searchText = ""
    
    let dummyProducts: [ProductReponse] = [
        ProductReponse(
            id: UUID(),
            sku: 123456,
            name: "990 v69",
            description: "This is a test description for the product.",
            brand: Brand.NewBalance,
            size: Size.size40,
            purchasePrice: 99.99,
            purchaseDate: Date(),
            salePrice: 100.00,
            saleDate: Date(),
            sold: false,
        ),
    ]
    
    var filteredProducts: [ProductReponse] {
        var products = productService.products
        if products.isEmpty {
            products = dummyProducts
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: .second, value: -1, to: calendar.date(byAdding: .month, value: 1, to: startOfMonth)!)!
        
        switch sortOption {
        case "All Ascending": return products.sorted { $0.sku < $1.sku }
        case "All Descending": return products.sorted { $0.sku > $1.sku }
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
        return products.sorted { $0.sku > $1.sku }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    if productService.isLoading {
                        ProgressView("Fetching products..")
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
                                            .padding(.leading, 2)
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
                        
                        if productService.products.isEmpty {
                            VStack(spacing: 15) {
                                Text("Server offline")
                                    .foregroundColor(.secondary)
                                Text("No products found")
                                    .foregroundColor(.secondary)
                                
                                // Refresh btn
                                Button("Refresh") {
                                    Task {
                                        try await productService.fetchProducts()
                                    }
                                }
                                .buttonStyle(.bordered)
                                .padding(.bottom, 200)
                            }
                            .padding()
                        }
                        
                        // Add btn
                        Button(action: {
                            showAddView = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Product")
                                    .bold()
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .cornerRadius(10)
                            .shadow(radius: 2)
                        }
                        .padding(.horizontal)
                        
                        .alert("Sure you want to delete this product?",
                               isPresented: $showConfirmation,
                               presenting: selectedItem) { product in
                            Button("Cancel", role: .cancel) {}
                            Button("Yes", role: .destructive) {
                                Task {
                                    do {
                                        try await productService.deleteProduct(id: product.id)
                                    } catch {
                                        print("Error deleting product: \(error)")
                                    }
                                }
                            }
                        } message: {_ in
                            Text("It will be gone forever!")
                        }
                    }
                    
                    Spacer()

                }
                Button(action: {
                    //scrollPosition = filteredProducts.last
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 44))
                        .foregroundColor(.blue.opacity(0.3))
                        .padding(12)
                }
                .padding(.leading, 100)
                .padding(.top, 350)
                
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
                        Button("All Ascending") { sortOption = "All Ascending" }
                        Button("All Descending") { sortOption = "All Descending" }
                        Button("Sold") { sortOption = "Sold" }
                        Button("Not Sold") { sortOption = "Not Sold" }
                    } label: {
                        Label("", systemImage: "chevron.down")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("This Month") { sortOption = "This Month" }
                    } label: {
                        Label("", systemImage: "calendar.badge.clock")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: InfoView()) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .padding()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "")
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
        CollectionView()
            .environment(ProductService())
    }
