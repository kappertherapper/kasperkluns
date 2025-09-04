import Foundation

@MainActor
@Observable
class ProductService {
    var products: [ProductReponse] = []
    var isLoading = false
    var errorMessage: String?
    
    private let baseURL = "http://localhost:8080"
    
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
                    String?, sold: Bool?) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/products") else {
            throw URLError(.badURL)
        }
        
        let newProduct = ProductRequest(name: name, sku: Sku, description: description, brand: brand, sold: sold, createdAt: Date.now)
        
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
        request.httpBody = try JSONEncoder().encode(updatedProduct)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        DispatchQueue.main.async {
            if let index = self.products.firstIndex(where: { $0.id == id }) {
                self.products[index].sku = updatedProduct.sku
                self.products[index].name = updatedProduct.name
                self.products[index].description = updatedProduct.description
                self.products[index].brand = updatedProduct.brand
                self.products[index].sold = updatedProduct.sold
                self.products[index].createdAt = updatedProduct.createdAt
                self.products[index].updatedAt = updatedProduct.updatedAt
                self.products[index].deletedAt = updatedProduct.deletedAt
            }
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
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        
        if let product = products.firstIndex(where: { $0.id == id }) {
            products.remove(at: product)
        }
    }
}


