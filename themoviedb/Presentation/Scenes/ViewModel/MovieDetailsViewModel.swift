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
final class MovieDetailsViewModel: ObservableObject {
    weak var delegate: MoviesDetailViewModelDelegate?
    @Published private(set) var movies: MoviesByYearDTO = .empty
    @Published private(set) var movieCasts: [Int: CastDTO] = [:]
    
    private let fetchSimilarMoviesUseCase: FetchSimilarMoviesUseCaseProtocol
    private let fetchMovieCastUseCase: FetchMovieCastUseCaseProtocol
    private let movie: MovieDTO
    
    @Published private(set) var state: ViewState = .idle {
        didSet {
            delegate?.viewModelDidUpdateState(self, state: state)
        }
    }
    
    init(fetchSimilarMoviesUseCase: FetchSimilarMoviesUseCaseProtocol,
         fetchMovieCastUseCase: FetchMovieCastUseCaseProtocol,
         movie: MovieDTO) {
        self.fetchSimilarMoviesUseCase = fetchSimilarMoviesUseCase
        self.fetchMovieCastUseCase = fetchMovieCastUseCase
        self.movie = movie
    }
    
    func loadsSimilarMovies() async {
        state = .loading
        
        do {
            let similarMovies = try await fetchSimilarMoviesUseCase.execute(movieId: movie.id)
            movies = similarMovies
            state = .loaded(movies)
            
            // Load credits for each similar movie
            for movie in similarMovies.allMovies.prefix(5) {
                await loadCreditsForMovie(movie.id)
            }
        } catch {
            state = .error(MovieError.from(error))
        }
    }
    
    func loadCreditsForMovie(_ movieId: Int) async {
        do {
            let credits = try await fetchMovieCastUseCase.execute(movieId: movieId)
            movieCasts[movieId] = credits
        } catch {
            print("Failed to load credits for movie \(movieId): \(error)")
        }
    }
}
