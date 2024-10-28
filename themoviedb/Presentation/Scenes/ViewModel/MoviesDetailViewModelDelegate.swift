//
//  MoviesDetailViewModelDelegate.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//


protocol MoviesDetailViewModelDelegate: AnyObject {
    func viewModelDidUpdateState(_ viewModel: MovieDetailsViewModel, state: ViewState)
}
