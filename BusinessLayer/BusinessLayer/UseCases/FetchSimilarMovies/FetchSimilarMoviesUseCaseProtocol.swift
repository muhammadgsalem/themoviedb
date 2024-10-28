//
//  FetchSimilarMoviesUseCaseProtocol.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//

import Foundation
import DataRepository

public protocol FetchSimilarMoviesUseCaseProtocol {
    func execute(movieId: Int) async throws -> MoviesByYearDTO
}
