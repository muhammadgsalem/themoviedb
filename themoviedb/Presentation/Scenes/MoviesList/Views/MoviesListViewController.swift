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
    @IBOutlet var MoviesTableView: UITableView!
    private let refreshControl = UIRefreshControl()
    private let coordinator: MoviesCoordinator
    private var viewModel: MoviesListViewModelProtocol
    private let imageLoadingService: ImageCacheService
    private let tableViewManager: MoviesTableViewManager
    private var searchTask: Task<Void, Never>?
    
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
        configureSearchBar()
        viewModel.delegate = self
        Task {
            await loadPopularMovies()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    ///Configures search bar
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search movies..."
        searchBar.showsCancelButton = true
        searchBar.searchBarStyle = .minimal
    }
    
    /// Configures the table view with necessary settings and registers cell types.
    private func configureTableView() {
        MoviesTableView.delegate = tableViewManager
        MoviesTableView.dataSource = tableViewManager
        MoviesTableView.prefetchDataSource = tableViewManager
        MoviesTableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        MoviesTableView.rowHeight = UITableView.automaticDimension
        MoviesTableView.estimatedRowHeight = 144
        MoviesTableView.separatorStyle = .none
        tableViewManager.delegate = self
    }
    
    /// Configures the refresh control for pull-to-refresh functionality.
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        MoviesTableView.refreshControl = refreshControl
    }
    
    /// Refreshes the data based on current state (search or popular movies).
    @objc private func refreshData() {
        // Cancel any ongoing search
        searchTask?.cancel()
        
        // Create new refresh task
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Reset pagination and clear current state
            self.viewModel.resetPagination()
            await MainActor.run {
                self.tableViewManager.reloadEverything()
            }
            
            // Determine whether to refresh search results or popular movies
            if let searchText = self.searchBar.text,
               !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Refresh search results
                await self.viewModel.searchMovies(query: searchText)
            } else {
                // Refresh popular movies
                await self.loadPopularMovies()
            }
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
        let alert = UIAlertController(title: "Error",
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            Task {
                await self?.viewModel.retryLastOperation()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: MoviesListViewModelDelegate
extension MoviesListViewController: MoviesListViewModelDelegate {
    func viewModelDidUpdateState(_ viewModel: MoviesListViewModelProtocol, state: ViewState) {
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

// MARK: MoviesTableViewManagerDelegate
extension MoviesListViewController: MoviesTableViewManagerDelegate {
    func movieTableViewManager(_ manager: MoviesTableViewManager, didSelectMovie movie: MovieDTO) {
        coordinator.showMovieDetails(movie)
    }
    
    var tableView: UITableView {
        return self.MoviesTableView
    }
}

// MARK: UISearchBarDelegate
extension MoviesListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Create new search task with debounce
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            // Wait for debounce period
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Check if task was cancelled during sleep
            if Task.isCancelled { return }
            
            await MainActor.run {
                self.viewModel.resetPagination()
            }
            
            if trimmedText.isEmpty {
                await self.loadPopularMovies()
            } else {
                do {
                    // Use the latest trimmed text from the search bar
                    if let currentText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                       currentText == trimmedText {
                        await self.viewModel.searchMovies(query: trimmedText)
                    }
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchTask?.cancel()
        
        let trimmedText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.viewModel.resetPagination()
            }
            
            if trimmedText.isEmpty {
                await self.loadPopularMovies()
            } else {
                await self.viewModel.searchMovies(query: trimmedText)
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchTask?.cancel()
        
        searchTask = Task { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.viewModel.resetPagination()
            }
            
            await self.loadPopularMovies()
        }
    }
}
