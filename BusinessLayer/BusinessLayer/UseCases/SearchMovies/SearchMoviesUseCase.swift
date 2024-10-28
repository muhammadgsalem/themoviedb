//
//  SearchMoviesUseCase.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//

import Foundation
import DataRepository

final class SearchMoviesUseCase: SearchMoviesUseCaseProtocol {
    private let movieRepository: MovieRepositoryProtocol

    init(movieRepository: MovieRepositoryProtocol) {
        self.movieRepository = movieRepository
    }

    func execute(query: String, page: Int) async throws -> MoviesByYearDTO {
        do {
            return try await movieRepository.searchMovies(query: query, page: page)
        } catch {
            throw self.mapError(error)
        }
    }
    
    private func mapError(_ error: Error) -> BusinessError {
        if let repositoryError = error as? RepositoryError {
            return .repositoryError(repositoryError)
        } else {
            return .unknown(error)
        }
    }
}
