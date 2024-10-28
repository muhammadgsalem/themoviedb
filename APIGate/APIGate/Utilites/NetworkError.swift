//
//  NetworkError.swift
//  APIGate
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case decodingError
    case unknownError(Error)
    case unauthorized
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData),
             (.decodingError, .decodingError):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.unknownError(lhsError), .unknownError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
