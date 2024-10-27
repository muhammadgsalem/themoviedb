//
//  MovieRepositoryProtocol.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


public protocol MovieRepositoryProtocol {
    func fetchPopularMovies(page: Int) async throws -> MoviesByYearDTO
    func searchMovies(query: String) async throws -> MoviesByYearDTO
    func fetchSimilarMovies(forMovie id: Int) async throws -> MoviesByYearDTO
}
