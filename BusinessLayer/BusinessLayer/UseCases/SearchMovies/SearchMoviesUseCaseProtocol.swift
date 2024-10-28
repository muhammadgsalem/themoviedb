//
//  SearchMoviesUseCaseProtocol.swift
//  BusinessLayer
//
//  Created by Jimmy on 28/10/2024.
//

import Foundation
import DataRepository

public protocol SearchMoviesUseCaseProtocol {
    func execute(query: String, page: Int) async throws -> MoviesByYearDTO
}
