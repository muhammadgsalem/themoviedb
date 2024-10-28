//
//  MoviesListViewModelProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

@MainActor
protocol MoviesListViewModelProtocol {
    var movies: MoviesByYearDTO { get }
    var delegate: MoviesListViewModelDelegate? { get set }
    func loadPopularMovies() async
    func resetPagination()
    func loadMorePopularMoviesIfNeeded(for page: Int)
}

enum ViewState: Equatable {
    case idle
    case loading
    case loaded(MoviesByYearDTO)
    case error(Error)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(lhsMovies), .loaded(rhsMovies)):
            return lhsMovies == rhsMovies
        case let (.error(lhsError), .error(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}
