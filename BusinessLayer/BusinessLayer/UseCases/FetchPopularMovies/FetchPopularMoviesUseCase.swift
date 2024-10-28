//
//  FetchPopularMoviesUseCase.swift
//  BusinessLayer
//
//  Created by Jimmy on 03/09/2024.
//

import Foundation
import DataRepository

final class FetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol {
    private let movieRepository: MovieRepositoryProtocol

    init(movieRepository: MovieRepositoryProtocol) {
        self.movieRepository = movieRepository
    }

    func execute(page: Int) async throws -> MoviesByYearDTO {
        do {
            return try await movieRepository.fetchPopularMovies(page: page)
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
