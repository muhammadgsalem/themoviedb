//
//  MoviesListViewModel.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//
import BusinessLayer
import DataRepository
import Foundation

@MainActor
class MoviesListViewModel: MoviesListViewModelProtocol {
    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol
    private var currentPage = 1
    private(set) var movies: MoviesByYearDTO = .empty
    private var isFetching = false
    private var hasMorePages = true
    weak var delegate: MoviesListViewModelDelegate?
    
    /// Indicates whether more pages can be loaded.
    var canLoadMorePages: Bool {
        !isFetching && hasMorePages
    }
    
    private var state: ViewState = .idle {
        didSet {
            delegate?.viewModelDidUpdateState(self, state: state)
        }
    }
    
    /// Initializes a new instance of `MoviesListViewModel`.
    ///
    /// - Parameter fetchPopularMoviesUseCase: The use case responsible for fetching movies from the repository.
    init(fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol) {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
    }
    
    func loadPopularMovies() async {
        guard canLoadMorePages else { return }
        isFetching = true
        
        // Only show loading state on first page
        if currentPage == 1 {
            state = .loading
        }
        
        do {
            let newMovies = try await fetchPopularMoviesUseCase.execute(page: currentPage)
            self.hasMorePages = (newMovies.totalPages > currentPage)
            
            // Merge new movies with existing ones
            var updatedMovies = self.movies
            
            for (year, movies) in newMovies.moviesByYear {
                if var existingMovies = updatedMovies.moviesByYear[year] {
                    // Append new movies to existing year group
                    existingMovies.append(contentsOf: movies)
                    updatedMovies.moviesByYear[year] = existingMovies
                } else {
                    // Create new year group with movies
                    updatedMovies.moviesByYear[year] = movies
                }
            }
            
            // Update total pages and results
            updatedMovies.totalPages = newMovies.totalPages
            updatedMovies.totalResults = newMovies.totalResults
            
            self.movies = updatedMovies
            self.currentPage += 1
            self.state = .loaded(self.movies)
        } catch {
            state = .error(error)
        }
    
        isFetching = false
    }
    
    /// Resets the pagination state.
    ///
    /// This method clears the current characters, resets the page counter, and sets the state to idle.
    func resetPagination() {
        currentPage = 1
        hasMorePages = true
        movies = .empty
        state = .idle
    }
    
    func loadMorePopularMoviesIfNeeded(for page: Int) {
        guard page == movies.moviesByYear.count - 1 else { return }
        Task {
            await loadPopularMovies()
        }
    }
}
