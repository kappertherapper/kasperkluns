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
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON:", jsonString)
            }
            
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
                    Brand?, sold: Bool?) async throws {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        guard let url = URL(string: "\(baseURL)/products") else {
            throw URLError(.badURL)
        }
        
        let newProduct = ProductRequest(name: name, sku: Sku, description: description, brand: brand, sold: sold)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(newProduct)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        
        let product = try JSONDecoder().decode(ProductReponse.self, from: data)
        products.append(product)
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw URLError(.badServerResponse)
        }
        
        if let index = products.firstIndex(where: { $0.id == id }) {
            products.remove(at: index)
        }
    }
}


