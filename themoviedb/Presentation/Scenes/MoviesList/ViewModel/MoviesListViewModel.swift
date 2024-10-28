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
    private var isFetching = false
    private var hasMorePages = true
    
    
    /// Initializes a new instance of `MoviesListViewModel`.
    ///
    /// - Parameter fetchPopularMoviesUseCase: The use case responsible for fetching movies from the repository.
    init(fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol) {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
    }
    
    
    
}
