//
//  MovieRepository.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//
import APIGate

public final class MovieRepository: MovieRepositoryProtocol {
    private let networking: NetworkProtocol
    
    public init(networking: NetworkProtocol) {
        self.networking = networking
    }
    
    public func fetchPopularMovies(page: Int) async throws -> MoviesByYearDTO {
        let endpoint = MovieEndpoint.popular(page: page)
        let response: MovieListResponse = try await networking.request(endpoint)
        return MoviesByYearDTO(response: response)
    }
    
    public func searchMovies(query: String, page: Int) async throws -> MoviesByYearDTO {
        let endpoint = MovieEndpoint.search(query: query, page: page)
        let response: MovieListResponse = try await networking.request(endpoint)
        return MoviesByYearDTO(response: response)
    }
    
    public func fetchSimilarMovies(forMovie id: Int) async throws -> MoviesByYearDTO {
        let endpoint = MovieEndpoint.similar(movieId: id)
        let response: MovieListResponse = try await networking.request(endpoint)
        return MoviesByYearDTO(response: response)
    }
}

// MARK: - Example Usage Extension
extension MoviesByYearDTO {
    public var numberOfMovies: Int {
        moviesByYear.values.reduce(0) { $0 + $1.count }
    }
    
    public func movies(forYear year: Int) -> [MovieDTO] {
        moviesByYear[year] ?? []
    }
    
    public var allMovies: [MovieDTO] {
        years.flatMap { movies(forYear: $0) }
    }
    
    public func hasMovies(in year: Int) -> Bool {
        (moviesByYear[year]?.isEmpty == false)
    }
}
