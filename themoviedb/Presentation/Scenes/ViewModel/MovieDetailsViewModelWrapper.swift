//
//  MovieDetailsViewModelWrapper.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

@MainActor
final class MovieDetailsViewModelWrapper: ObservableObject {
    private let wrapped: MovieDetailsViewModelProtocol
    @Published private(set) var movies: MoviesByYearDTO = .empty
    
    init(wrapped: MovieDetailsViewModelProtocol) {
        self.wrapped = wrapped
    }
    
    func loadsSimilarMovies() async {
        await wrapped.loadsSimilarMovies()
        // Update the published movies property when the wrapped view model changes
        self.movies = wrapped.movies
    }
}
