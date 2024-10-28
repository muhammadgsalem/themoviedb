//
//  CreditResponse.swift
//  DataRepository
//
//  Created by Jimmy on 28/10/2024.
//


public struct CreditResponse: Decodable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

public struct CastMember: Identifiable, Decodable {
    public let id: Int
    let name: String
    let character: String
    let profilePath: String?
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, popularity
        case profilePath = "profile_path"
    }
}

public struct CrewMember: Identifiable, Decodable {
    public let id: Int
    let name: String
    let department: String
    let job: String
    let profilePath: String?
    let popularity: Double
    
    enum CodingKeys: String, CodingKey {
        case id, name, department, job, popularity
        case profilePath = "profile_path"
    }
}