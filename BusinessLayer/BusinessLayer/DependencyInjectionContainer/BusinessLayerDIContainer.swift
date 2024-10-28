//
//  BusinessLayerDIContainer.swift
//  BusinessLayer
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation
import DataRepository

public final class BusinessLayerDIContainer {
    public static let shared = BusinessLayerDIContainer()
    
    private let dataRepositoryDIContainer: DataRepositoryDIContainer
    
    private init(dataRepositoryDIContainer: DataRepositoryDIContainer = .shared) {
        self.dataRepositoryDIContainer = dataRepositoryDIContainer
    }
    
    public func makeFetchPopularMoviesUseCase() -> FetchPopularMoviesUseCaseProtocol {
        FetchPopularMoviesUseCase(movieRepository: dataRepositoryDIContainer.makeMovieRepository())
    }
    
    public func makeSearchMoviesUseCase() -> SearchMoviesUseCaseProtocol {
        SearchMoviesUseCase(movieRepository: dataRepositoryDIContainer.makeMovieRepository())
    }
    
    public func makeFetchSimilarMoviesUseCase() -> FetchSimilarMoviesUseCaseProtocol {
        FetchSimilarMoviesUseCase(movieRepository: dataRepositoryDIContainer.makeMovieRepository())
    }
    
    public func makeFetchMovieCastUseCase() -> FetchMovieCastUseCaseProtocol {
        FetchMovieCastUseCase(movieRepository: dataRepositoryDIContainer.makeMovieRepository())
    }
}
