//
//  fetchMovieCastUseCase.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//

import Foundation
import DataRepository

final class FetchMovieCastUseCase: FetchMovieCastUseCaseProtocol {
    private let movieRepository: MovieRepositoryProtocol

    init(movieRepository: MovieRepositoryProtocol) {
        self.movieRepository = movieRepository
    }

    func execute(movieId: Int) async throws -> CastDTO {
        do {
            return try await movieRepository.fetchMovieCredits(forMovie: movieId)
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
