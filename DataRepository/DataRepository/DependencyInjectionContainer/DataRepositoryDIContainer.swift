//
//  DataRepositoryDIContainer.swift
//  DataRepository
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation
import APIGate

public final class DataRepositoryDIContainer {
    public static let shared = DataRepositoryDIContainer()
    
    private let apiGateDIContainer: APIGateDIContainer
    
    private init(apiGateDIContainer: APIGateDIContainer = .shared) {
        self.apiGateDIContainer = apiGateDIContainer
    }
    
    public func makeMovieRepository() -> MovieRepositoryProtocol {
        MovieRepository(networking: apiGateDIContainer.makeNetworking())
    }
}
