//
//  MovieDetailsViewModel.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import BusinessLayer
import DataRepository
import Foundation

@MainActor
final class MovieDetailsViewModel: MovieDetailsViewModelProtocol, ObservableObject {
    weak var delegate: MoviesDetailViewModelDelegate?
    @Published private(set) var movies: MoviesByYearDTO = .empty
    private let fetchSimilarMoviesUseCase: FetchSimilarMoviesUseCaseProtocol
    private let movie: MovieDTO
    @Published private(set) var state: ViewState = .idle {
        didSet {
            delegate?.viewModelDidUpdateState(self, state: state)
        }
    }
    
    init(fetchSimilarMoviesUseCase: FetchSimilarMoviesUseCaseProtocol,
         movie: MovieDTO) {
        self.fetchSimilarMoviesUseCase = fetchSimilarMoviesUseCase
        self.movie = movie
    }
    
    func loadsSimilarMovies() async {
        state = .loading
        
        do {
            let similarMovies = try await fetchSimilarMoviesUseCase.execute(movieId: movie.id)
            movies = similarMovies
            state = .loaded(movies)
        } catch {
            state = .error(MovieError.from(error))
        }
    }
}
