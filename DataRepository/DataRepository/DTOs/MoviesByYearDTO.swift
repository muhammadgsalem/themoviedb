//
//  MoviesByYearDTO.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


public struct MoviesByYearDTO {
    public let years: [Int]  // Sorted years for easy access
    public let moviesByYear: [Int: [MovieDTO]]
    public let totalResults: Int
    public let currentPage: Int
    public let totalPages: Int
    
    public init(response: MovieListResponse) {
        let groupedMovies = Dictionary(grouping: response.results) { movie in
            Calendar.current.component(.year, from: movie.releaseDate)
        }
        
        self.moviesByYear = groupedMovies.mapValues { movies in
            movies.map(MovieDTO.init)
                .sorted { $0.releaseDate > $1.releaseDate } // Sort by date within year
        }
        
        self.years = groupedMovies.keys.sorted(by: >)  // Sort years descending
        self.totalResults = response.totalResults
        self.currentPage = response.page
        self.totalPages = response.totalPages
    }
}

public struct MovieDTO: Identifiable {
    public let id: Int
    public let title: String
    public let overview: String
    public let posterPath: String?
    public let backdropPath: String?
    public let releaseDate: Date
    public let voteAverage: Double
    public let voteCount: Int
    public let genres: [Int]
    public let popularity: Double
    
    public var posterURL: URL? {
        posterPath.flatMap { path in
            URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
    }
    
    public var backdropURL: URL? {
        backdropPath.flatMap { path in
            URL(string: "https://image.tmdb.org/t/p/original\(path)")
        }
    }
    
    public var releaseYear: Int {
        Calendar.current.component(.year, from: releaseDate)
    }
    
    public var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }
    
    init(movie: Movie) {
        self.id = movie.id
        self.title = movie.title
        self.overview = movie.overview
        self.posterPath = movie.posterPath
        self.backdropPath = movie.backdropPath
        self.releaseDate = movie.releaseDate
        self.voteAverage = movie.voteAverage
        self.voteCount = movie.voteCount
        self.genres = movie.genreIds
        self.popularity = movie.popularity
    }
}