//
//  MovieEndpoint.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//

import Foundation
import APIGate

enum MovieEndpoint {
    case popular(page: Int = 1)
    case search(query: String, page: Int = 1)
    case movieDetails(id: Int)
    case similar(movieId: Int, page: Int = 1)
    case credits(movieId: Int)
}

// MARK: - Constants
private extension MovieEndpoint {
    enum Constants {
        enum Path {
            static let movie = "/movie"
            static let search = "/search/movie"
            static let similar = "/similar"
            static let credits = "/credits"
        }
        
        enum Parameters {
            static let page = "page"
            static let query = "query"
        }
        
        enum Headers {
            static let accept = "Accept"
            static let authorization = "Authorization"
            static let contentType = "application/json"
        }
    }
}

// MARK: - Endpoint
extension MovieEndpoint: Endpoint {
    var path: String {
        let baseURL = APIConfiguration.shared.baseURL
        
        switch self {
        case .popular:
            return baseURL + Constants.Path.movie + "/popular"
        case .search:
            return baseURL + Constants.Path.search
        case .movieDetails(let id):
            return baseURL + Constants.Path.movie + "/\(id)"
        case .similar(let movieId, _):
            return baseURL + Constants.Path.movie + "/\(movieId)" + Constants.Path.similar
        case .credits(let movieId):
            return baseURL + Constants.Path.movie + "/\(movieId)" + Constants.Path.credits
        }
    }
    
    var method: HTTPMethod {
        .get
    }
    
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        
        switch self {
        case .popular(let page), .similar(_, let page):
            params[Constants.Parameters.page] = page
            
        case .search(let query, let page):
            params[Constants.Parameters.query] = query
            params[Constants.Parameters.page] = page
            
        case .movieDetails, .credits:
            break
        }
        
        return params.isEmpty ? nil : params
    }
    
    var headers: [String: String]? {
        [
            Constants.Headers.accept: Constants.Headers.contentType,
            Constants.Headers.authorization: "Bearer \(APIConfiguration.shared.bearerToken)"
        ]
    }
}
