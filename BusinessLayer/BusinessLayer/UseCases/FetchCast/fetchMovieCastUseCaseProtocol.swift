//
//  fetchMovieCastUseCaseProtocol.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//

import Foundation
import DataRepository

public protocol FetchMovieCastUseCaseProtocol {
    func execute(movieId: Int) async throws -> CastDTO
}
