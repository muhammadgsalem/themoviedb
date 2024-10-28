//
//  APIGateDIContainer.swift
//  APIGate
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation

public final class APIGateDIContainer {
    public static let shared = APIGateDIContainer()
    
    private init() {}
    
    public func makeNetworking() -> NetworkProtocol {
        return URLSessionNetworking()
    }
    
    public func makeEndpoint(path: String, method: HTTPMethod, parameters: [String: Any]? = nil, headers: [String: String]? = nil) -> Endpoint {
        return ConcreteEndpoint(path: path, method: method, parameters: parameters, headers: headers)
    }
}

private struct ConcreteEndpoint: Endpoint {
    let path: String
    let method: HTTPMethod
    let parameters: [String: Any]?
    let headers: [String: String]?
}
