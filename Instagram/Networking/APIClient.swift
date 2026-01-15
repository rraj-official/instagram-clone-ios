import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unknown
}

protocol APIClientProtocol {
    func fetch<T: Decodable>(_ endpoint: APIEndpoints, method: String, body: Encodable?) async throws -> T
    func perform(_ endpoint: APIEndpoints, method: String, body: Encodable?) async throws
}

class APIClient: APIClientProtocol {
    static let shared = APIClient()
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetch<T: Decodable>(_ endpoint: APIEndpoints, method: String = "GET", body: Encodable? = nil) async throws -> T {
        let (data, _) = try await request(endpoint, method: method, body: body)
        
        // Debugging: Print the JSON response to see the structure
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 API Response: \(jsonString)")
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding Error for \(T.self): \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    func perform(_ endpoint: APIEndpoints, method: String = "GET", body: Encodable? = nil) async throws {
        _ = try await request(endpoint, method: method, body: body)
    }
    
    private func request(_ endpoint: APIEndpoints, method: String, body: Encodable?) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            return (data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
