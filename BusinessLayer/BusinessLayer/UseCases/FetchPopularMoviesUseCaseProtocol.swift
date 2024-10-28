//
//  FetchPopularMoviesUseCase.swift
//  BusinessLayer
//
//  Created by Jimmy on 03/09/2024.
//

import Foundation
import DataRepository

public protocol FetchPopularMoviesUseCaseProtocol {
    func execute(page: Int) async throws -> MoviesByYearDTO
}

