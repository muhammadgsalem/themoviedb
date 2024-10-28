//
//  FetchSimilarMoviesUseCase.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//
import Foundation
import DataRepository

final class FetchSimilarMoviesUseCase: FetchSimilarMoviesUseCaseProtocol {
    private let movieRepository: MovieRepositoryProtocol

    init(movieRepository: MovieRepositoryProtocol) {
        self.movieRepository = movieRepository
    }

    func execute(movieId: Int) async throws -> MoviesByYearDTO {
        do {
            return try await movieRepository.fetchSimilarMovies(forMovie: movieId)
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
