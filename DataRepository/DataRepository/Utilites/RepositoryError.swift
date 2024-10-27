//
//  RepositoryError.swift
//  DataRepository
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation
import APIGate


public enum RepositoryError: Error, Equatable {
    case invalidRequest
    case invalidResponse
    case serverError(statusCode: Int)
    case noData
    case unknown(Error)

    public static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidRequest, .invalidRequest),
             (.invalidResponse, .invalidResponse),
             (.noData, .noData):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.unknown(lhsError), .unknown(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
