//
//  MoviesByYearDTO.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


public struct MoviesByYearDTO {
    public let years: [Int]  // Sorted years for easy access
    public var moviesByYear: [Int: [MovieDTO]]
    public var totalResults: Int
    public let currentPage: Int
    public var totalPages: Int
    
    public init(
        years: [Int] = [],
        moviesByYear: [Int: [MovieDTO]] = [:],
        totalResults: Int = 0,
        currentPage: Int = 1,
        totalPages: Int = 1
    ) {
        self.years = years
        self.moviesByYear = moviesByYear
        self.totalResults = totalResults
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
    
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
    
    public static func == (lhs: MoviesByYearDTO, rhs: MoviesByYearDTO) -> Bool {
        lhs.currentPage == rhs.currentPage
    }
    
    public static var empty: MoviesByYearDTO {
        MoviesByYearDTO(
            years: [],
            moviesByYear: [:],
            totalResults: 0,
            currentPage: 1,
            totalPages: 1
        )
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
    
    public static func == (lhs: MovieDTO, rhs: MovieDTO) -> Bool {
        lhs.id == rhs.id

    }
}
