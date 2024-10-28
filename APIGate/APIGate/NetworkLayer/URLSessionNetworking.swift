//
//  URLSessionNetworking.swift
//  APIGate
//
//  Created by Jimmy on 03/09/2024.
//

import Foundation

/// A networking service that uses `URLSession` to perform network requests.
final class URLSessionNetworking: NetworkProtocol {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    
    /// Initializes a new instance of `URLSessionNetworking`.
    ///
    /// - Parameters:
    ///   - session: The `URLSessionProtocol` to use for network requests. Defaults to `URLSession.shared`.
    ///   - decoder: The `JSONDecoder` to use for decoding responses. Defaults to a new instance.
    init(session: URLSessionProtocol = URLSession.shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    /// Performs a network request and decodes the response.
    ///
    /// - Parameter endpoint: The `Endpoint` describing the request to be made.
    /// - Returns: A decoded object of type `T`.
    /// - Throws: A `NetworkError` if the request fails or the response cannot be decoded.
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        guard let url = URL(string: endpoint.path) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        configureRequest(&request, with: endpoint)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    /// Configures a URLRequest with the parameters from an Endpoint.
    ///
    /// - Parameters:
    ///   - request: The URLRequest to configure.
    ///   - endpoint: The Endpoint containing the configuration information.
    private func configureRequest(_ request: inout URLRequest, with endpoint: Endpoint) {
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let parameters = endpoint.parameters {
            request.url = request.url?.appendingQueryParameters(parameters)
        }
    }
}
