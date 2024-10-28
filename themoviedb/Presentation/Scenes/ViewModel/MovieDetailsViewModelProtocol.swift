//
//  MovieDetailsViewModelProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

/// Protocol defining the interface for the MoviesListViewModel
@MainActor
protocol MovieDetailsViewModelProtocol: AnyObject {
    // MARK: - Properties
    /// Current movies data organized by year
    var movies: MoviesByYearDTO { get }
    
    
    /// Delegate to receive state updates
    var delegate: MoviesDetailViewModelDelegate? { get set }
    
    // MARK: - Movie Loading Methods
    /// Loads Similar movies
    /// - Returns: Asynchronously loads Similar movies and updates state
    func loadsSimilarMovies() async
}
