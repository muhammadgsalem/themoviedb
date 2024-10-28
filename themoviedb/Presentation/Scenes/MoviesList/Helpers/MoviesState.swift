//
//  MoviesState.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

enum MoviesState {
    case idle
    case loading
    case loaded(MoviesByYearDTO)
    case error(Error)
}
