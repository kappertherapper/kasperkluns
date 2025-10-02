import Foundation

@MainActor
@Observable
class ProductService {
    var products: [ProductReponse] = []
    var isLoading = false
    var errorMessage: String?
    
//    private let baseURL = "http://localhost:8080"
    private let baseURL = "http://10.44.0.129:8080"
    
// MARK: - READ
    func fetchProducts() async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let url = URL(string: "\(baseURL)/products") else {
                throw URLError(.badURL)
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            //Test
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("JSON:", jsonString)
//            }
            
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            products = try decoder.decode([ProductReponse].self, from: data)
            
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            print("Error loading products: \(error)")
        }
    }
    
    func getProduct(id: UUID) async throws -> ProductReponse {
        isLoading = true
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let product = try JSONDecoder().decode(ProductReponse.self, from: data)
        
        guard product.id == id else {
            throw NSError(domain: "ProductMismatch", code: 0, userInfo: [NSLocalizedDescriptionKey: "Product ID does not match parameter id"])
        }
        return product
    }
    
//MARK: - ADD
    func addProduct(name: String, Sku: Int, description: String?, brand:
                    String, size: String, purchasePrice: Double, purchaseDate: Date, sold: Bool?) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            guard let url = URL(string: "\(baseURL)/products") else {
                throw URLError(.badURL)
            }
            
            let newProduct = ProductRequest(name: name,
                                            sku: Sku,
                                            description: description,
                                            brand: brand,
                                            size: size,
                                            purchasePrice: purchasePrice,
                                            purchaseDate: purchaseDate,
                                            )
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(newProduct)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 201 else {
                throw URLError(.badServerResponse)
            }
            
            let product = try JSONDecoder().decode(ProductReponse.self, from: data)
            products.append(product)
        } catch {
            errorMessage = "Failed to add new product: \(error.localizedDescription)"
            print("Error adding new product: \(error)")
        }
    }
    
//MARK: - EDIT
    func editProduct(id: UUID ,updatedProduct: ProductReponse) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(updatedProduct)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        await MainActor.run {
            if let index = self.products.firstIndex(where: { $0.id == id }) {
                var product = self.products[index]
                product = updatedProduct
                self.products[index] = product
            }
        }
    }
    
    func updateProductSold(id: UUID, salePrice: Double, saleDate: Date, sold: Bool) async throws {
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
    
        request.httpBody = try encoder.encode(ProductSold(
            salePrice: salePrice,
            saleDate: saleDate,
            sold: sold
        ))
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        guard let index = products.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "Product not found", code: 0)
        }
        
        var updatedProduct = products[index]
        updatedProduct.sold = sold
        updatedProduct.salePrice = salePrice
        updatedProduct.saleDate = saleDate
        
        await MainActor.run {
            products[index] = updatedProduct
        }
    }
    
//MARK: - DELETE
    func deleteProduct(id: UUID) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/products/\(id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        if let product = products.firstIndex(where: { $0.id == id }) {
            products.remove(at: product)
        }
    }
    
//MARK: - HELPERS
    func getProductCount() async -> Int {
        do {
            try await fetchProducts()
            return products.count+1
        } catch {
            print("Fejl: \(error)")
            return 0
        }
    }
    
    func getTotalRevenue() async -> Double {
        var total = 0.0
        for product in products {
            total += product.purchasePrice
        }
        return total
    }
    
    func getTotalProfit() async -> Double {
        var total = 0.0
        for product in products {
            if (product.sold == true) {
                total += product.revenue()
            }
        }
        return total
    }
    
    func getProfitPerProduct() async -> Double {
        let soldCount = Double(products.filter { $0.sold }.count)
        guard soldCount > 0 else { return 0 }
        return await getTotalProfit() / soldCount
    }
    
    func getTotalProfitAndCountByMonth(month: Int, year: Int) async -> (total: Double, count: Int) {
        var total = 0.0
        var count = 0
        let calendar = Calendar.current
        
        for product in products {
            if product.sold, let saleDate = product.saleDate {
                let saleMonth = calendar.component(.month, from: saleDate)
                let saleYear = calendar.component(.year, from: saleDate)
                
                if saleMonth == month && saleYear == year {
                    total += product.revenue()
                    count += 1
                }
            }
        }
        return (total, count)
    }
    
    func getTotalProfitByQuarter(quarter: Int) async -> Double {
        var total = 0.0
        let calendar = Calendar.current
        
        for product in products {
            if product.sold, let saleDate = product.saleDate {
                let saleMonth = calendar.component(.month, from: saleDate)
                let saleQuarter = (saleMonth - 1) / 3 + 1
                
                if saleQuarter == quarter  {
                    total += product.revenue()
                }
            }
        }
        return total
    }
}


