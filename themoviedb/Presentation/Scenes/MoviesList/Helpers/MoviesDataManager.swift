//
//  MoviesDataManager.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import BusinessLayer
import DataRepository

actor MoviesDataManager {
    private var currentMovies: MoviesByYearDTO = .empty
    
    var movies: MoviesByYearDTO {
        get {
            currentMovies
        }
    }
    
    func reset() {
        currentMovies = .empty
    }
    
    func update(with newMovies: MoviesByYearDTO, isFirstPage: Bool) {
        if isFirstPage {
            currentMovies = newMovies
        } else {
            mergeNewMovies(newMovies)
        }
    }
    
    private func mergeNewMovies(_ newMovies: MoviesByYearDTO) {
        for (year, movies) in newMovies.moviesByYear {
            if var existingMovies = currentMovies.moviesByYear[year] {
                let newUniqueMovies = movies.filter { newMovie in
                    !existingMovies.contains { $0.id == newMovie.id }
                }
                existingMovies.append(contentsOf: newUniqueMovies)
                currentMovies.moviesByYear[year] = existingMovies.sorted { $0.popularity > $1.popularity }
            } else {
                currentMovies.moviesByYear[year] = movies
            }
        }
        
        currentMovies.totalPages = newMovies.totalPages
        currentMovies.totalResults = newMovies.totalResults
    }
}
