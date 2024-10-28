//
//  CastDTO.swift
//  DataRepository
//
//  Created by Jimmy on 28/10/2024.
//


public struct CastDTO {
    public let actors: [CastMemberDTO]
    public let directors: [CastMemberDTO]
    
    // Add this initializer
    public init(actors: [CastMemberDTO], directors: [CastMemberDTO]) {
        self.actors = actors
        self.directors = directors
    }
    
    public init(from response: CreditResponse) {
        // Get top 5 actors sorted by popularity
        self.actors = response.cast
            .sorted { $0.popularity > $1.popularity }
            .prefix(5)
            .map { CastMemberDTO(id: $0.id, name: $0.name, popularity: $0.popularity) }
        
        // Get top 5 directors sorted by popularity
        self.directors = response.crew
            .filter { $0.job.lowercased() == "director" }
            .sorted { $0.popularity > $1.popularity }
            .prefix(5)
            .map { CastMemberDTO(id: $0.id, name: $0.name, popularity: $0.popularity) }
    }
    
    public static var empty: CastDTO {
        CastDTO(actors: [], directors: [])
    }
}

public struct CastMemberDTO: Identifiable {
    public let id: Int
    public let name: String
    public let popularity: Double
}
