//
//  APIConfigurationProtocol.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


protocol APIConfigurationProtocol {
    var bearerToken: String { get }
    var baseURL: String { get }
    var imageBaseURL: String { get }
}