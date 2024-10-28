//
//  MoviesListViewModelProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

/// Protocol defining the interface for the MoviesListViewModel
@MainActor
protocol MoviesListViewModelProtocol: AnyObject {
    // MARK: - Properties
    /// Current movies data organized by year
    var movies: MoviesByYearDTO { get }
    
    /// Indicates if more pages can be loaded
    var canLoadMorePages: Bool { get }
    
    /// Delegate to receive state updates
    var delegate: MoviesListViewModelDelegate? { get set }
    
    // MARK: - Movie Loading Methods
    /// Loads popular movies
    /// - Returns: Asynchronously loads popular movies and updates state
    func loadPopularMovies() async
    
    /// Searches for movies with the given query
    /// - Parameter query: The search query string
    /// - Returns: Asynchronously searches movies and updates state
    func searchMovies(query: String) async
    
    /// Resets pagination state
    func resetPagination()
    
    /// Loads more movies if needed for the given index
    /// - Parameter index: The current section index being displayed
    func loadMoreMoviesIfNeeded(for index: Int)
    
    /// Retries the last failed operation
    func retryLastOperation() async
}

/// View state enum representing different states of the view
enum ViewState: Equatable {
    /// Initial state
    case idle
    
    /// Loading state during data fetch
    case loading
    
    /// Data loaded successfully
    case loaded(MoviesByYearDTO)
    
    /// Error state with associated error
    case error(Error)
    
    static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading):
            return true
        case let (.loaded(lhsData), .loaded(rhsData)):
            return lhsData.totalResults == rhsData.totalResults
        case let (.error(lhsError), .error(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Constants
extension MoviesListViewModelProtocol {
    /// Default page size for API requests
    static var defaultPageSize: Int { 20 }
    
    /// Maximum cached pages
    static var maxCachedPages: Int { 3 }
}
