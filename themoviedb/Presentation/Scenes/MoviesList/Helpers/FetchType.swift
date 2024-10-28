//
//  FetchType.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

enum FetchType: Hashable {
    case popular

    case search(String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .popular:

            hasher.combine(0)

        case .search(let query):

            hasher.combine(1)

            hasher.combine(query)
        }
    }

    static func == (lhs: FetchType, rhs: FetchType) -> Bool {
        switch (lhs, rhs) {
        case (.popular, .popular):

            return true

        case (.search(let query1), .search(let query2)):

            return query1 == query2

        default:

            return false
        }
    }
}
