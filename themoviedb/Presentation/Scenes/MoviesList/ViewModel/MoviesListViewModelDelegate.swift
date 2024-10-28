//
//  MoviesListViewModelDelegate.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//


import Foundation
/// Protocol for view model state updates
protocol MoviesListViewModelDelegate: AnyObject {
    func viewModelDidUpdateState(_ viewModel: MoviesListViewModelProtocol, state: ViewState)
}
