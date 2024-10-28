//
//  MoviesListViewController.swift
//  themoviedb
//
//  Created by Jimmy on 27/10/2024.
//

import UIKit
import DataRepository
import SwiftUI


class MoviesListViewController: UIViewController {
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var tableView: UITableView!
    private let coordinator: MoviesCoordinator
    private let viewModel: MoviesListViewModelProtocol
    private let imageLoadingService: ImageCacheService
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    /// Initializes a new instance of `MoviesListViewController`.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator responsible for handling navigation from this view controller.
    ///   - viewModel: The view model that provides data and business logic for this view controller.
    ///   - imageLoadingService: The service responsible for loading and caching movies images.
    init(coordinator: MoviesCoordinator,
         viewModel: MoviesListViewModelProtocol,
         imageLoadingService: ImageCacheService) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.imageLoadingService = imageLoadingService
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
