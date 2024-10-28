//
//  MoviesListViewController.swift
//  themoviedb
//
//  Created by Jimmy on 27/10/2024.
//

import DataRepository
import SwiftUI
import UIKit

class MoviesListViewController: UIViewController {
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private let coordinator: MoviesCoordinator
    private var viewModel: MoviesListViewModelProtocol
    private let imageLoadingService: ImageCacheService
    private let tableViewManager: MoviesTableViewManager
    
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// Initializes a new instance of `MoviesListViewController`.
    ///
    /// - Parameters:
    ///   - coordinator: The coordinator responsible for handling navigation from this view controller.
    ///   - viewModel: The view model that provides data and business logic for this view controller.
    ///   - imageLoadingService: The service responsible for loading and caching movies images.
    init(coordinator: MoviesCoordinator,
         viewModel: MoviesListViewModelProtocol,
         imageLoadingService: ImageCacheService)
    {
        self.coordinator = coordinator
        self.viewModel = viewModel
        self.imageLoadingService = imageLoadingService
        self.tableViewManager = MoviesTableViewManager(viewModel: viewModel,
                                                           imageLoadingService: imageLoadingService)
        super.init(nibName: nil, bundle: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureRefreshControl()
        setupActivityIndicator()
        viewModel.delegate = self
        Task {
            await loadPopularMovies()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    /// Configures the table view with necessary settings and registers cell types.
    private func configureTableView() {
        tableView.delegate = tableViewManager
        tableView.dataSource = tableViewManager
        tableView.prefetchDataSource = tableViewManager
        tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 144
        tableView.separatorStyle = .none
        tableViewManager.delegate = self
    }
    
    
    /// Configures the refresh control for pull-to-refresh functionality.
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    
    /// Refreshes the character data.
    @objc private func refreshData() {
        viewModel.resetPagination()
        tableViewManager.reloadEverything() // Clear the current state
        Task {
            await loadPopularMovies()
        }
    }
    
    
    /// Sets up the activity indicator for loading states.
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    /// loadPopularMovies from the view model.
    private func loadPopularMovies() async {
        await viewModel.loadPopularMovies()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Shows the loading indicator and disables user interaction.
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
            self?.view.isUserInteractionEnabled = false
        }
    }

    /// Hides the loading indicator and enables user interaction.
    private func hideLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    /// Displays an error alert to the user.
    ///
    /// - Parameter error: The error to display.
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            Task {
                await self?.loadPopularMovies()
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}


extension MoviesListViewController: MoviesListViewModelDelegate {
    func viewModelDidUpdateState(_ viewModel: MoviesListViewModel, state: ViewState) {
        DispatchQueue.main.async { [weak self] in
            switch state {
            case .idle:
                self?.tableViewManager.reloadData() 
            case .loading:
                if viewModel.movies.moviesByYear.isEmpty {
                    self?.showLoadingIndicator()
                }
            case .loaded:
                self?.hideLoadingIndicator()
                self?.tableViewManager.reloadData()
                self?.refreshControl.endRefreshing()
            case .error(let error):
                self?.hideLoadingIndicator()
                self?.showError(error)
                self?.refreshControl.endRefreshing()
            }
        }
    }
}

extension MoviesListViewController: MoviesTableViewManagerDelegate {
    func movieTableViewManager(_ manager: MoviesTableViewManager, didSelectMovie movie: MovieDTO) {
        coordinator.showMovieDetails(movie)
    }
    
}
