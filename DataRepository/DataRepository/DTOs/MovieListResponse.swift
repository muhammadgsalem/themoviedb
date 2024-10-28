//
//  MovieListResponse.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


public struct MovieListResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

// MARK: - Movie Model
public struct Movie: Identifiable, Decodable {
    public let id: Int
    let title: String
    let originalTitle: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: Date
    let voteAverage: Double
    let voteCount: Int
    let popularity: Double
    let genreIds: [Int]
    let adult: Bool
    let video: Bool
    let originalLanguage: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case originalTitle = "original_title"
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
        case popularity
        case genreIds = "genre_ids"
        case adult
        case video
        case originalLanguage = "original_language"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        
        // Handle release date
        if let dateString = try container.decodeIfPresent(String.self, forKey: .releaseDate),
           !dateString.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: dateString) {
                releaseDate = date
            } else {
                releaseDate = Date(timeIntervalSince1970: 0) // Default date if parsing fails
            }
        } else {
            releaseDate = Date(timeIntervalSince1970: 0) // Default date if no date provided
        }
        
        voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        popularity = try container.decode(Double.self, forKey: .popularity)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        adult = try container.decode(Bool.self, forKey: .adult)
        video = try container.decode(Bool.self, forKey: .video)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
    }
}

// MARK: - Movie Extensions
extension Movie {
    var posterURL: URL? {
        posterPath.flatMap { path in
            URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
    }
    
    var backdropURL: URL? {
        backdropPath.flatMap { path in
            URL(string: "https://image.tmdb.org/t/p/original\(path)")
        }
    }
    
    var releaseYear: Int {
        Calendar.current.component(.year, from: releaseDate)
    }
    
    var formattedVoteAverage: String {
        String(format: "%.1f", voteAverage)
    }
    
    var formattedReleaseDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: releaseDate)
    }
}

// MARK: - Custom Error Handling
extension MovieListResponse {
    enum MovieError: Error {
        case invalidDate
        case missingRequiredField(String)
        case invalidResponse
        
        var localizedDescription: String {
            switch self {
            case .invalidDate:
                return "Invalid date format in response"
            case .missingRequiredField(let field):
                return "Missing required field: \(field)"
            case .invalidResponse:
                return "Invalid response format"
            }
        }
    }
}


