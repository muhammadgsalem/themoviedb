//
//  NetworkProtocol.swift
//  NetworkProtocol
//
//  Created by Jimmy on 03/09/2024.
//

import Foundation

public protocol NetworkProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

