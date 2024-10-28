//
//  MoviesListViewModelDelegate.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//


import Foundation
protocol MoviesListViewModelDelegate: AnyObject {
    func viewModelDidUpdateState(_ viewModel: MoviesListViewModel, state: ViewState)
}
