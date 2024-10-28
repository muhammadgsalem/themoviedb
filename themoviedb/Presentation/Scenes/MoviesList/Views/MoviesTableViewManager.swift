//
//  MoviesTableViewManager.swift
//  themoviedb
//
//  Created by Jimmy on 06/09/2024.
//

import UIKit
import DataRepository

protocol MoviesTableViewManagerDelegate: AnyObject {
    func movieTableViewManager(_ manager: MoviesTableViewManager, didSelectMovie movie: MovieDTO)
}

@MainActor
final class MoviesTableViewManager: NSObject {
    // MARK: - Properties
    private let viewModel: MoviesListViewModelProtocol
    private let imageLoadingService: ImageCacheService
    weak var delegate: MoviesTableViewManagerDelegate?
    private var currentMoviesByYear: [Int: [MovieDTO]] = [:]
    
    // MARK: - Initialization
    init(viewModel: MoviesListViewModelProtocol,
         imageLoadingService: ImageCacheService) {
        self.viewModel = viewModel
        self.imageLoadingService = imageLoadingService
        super.init()
    }
    
    // MARK: - Helper Methods
    private func movie(at indexPath: IndexPath) -> MovieDTO? {
        let years = getYears()
        guard indexPath.section < years.count else { return nil }
        let year = years[indexPath.section]
        return viewModel.movies.moviesByYear[year]?[indexPath.row]
    }
    
    private func getYears() -> [Int] {
        return Array(viewModel.movies.moviesByYear.keys).sorted(by: >)
    }
    
    private func calculateTableViewUpdates(oldMovies: [Int: [MovieDTO]], newMovies: [Int: [MovieDTO]]) -> (
        sectionsToAdd: IndexSet,
        sectionsToRemove: IndexSet,
        rowsToAdd: [IndexPath],
        rowsToRemove: [IndexPath]
    ) {
        let oldYears = Set(oldMovies.keys)
        let newYears = Set(newMovies.keys)
        
        let addedYears = newYears.subtracting(oldYears)
        let removedYears = oldYears.subtracting(newYears)
        
        var rowsToAdd: [IndexPath] = []
        var rowsToRemove: [IndexPath] = []
        
        // Handle existing sections
        let commonYears = oldYears.intersection(newYears)
        for year in commonYears {
            let oldCount = oldMovies[year]?.count ?? 0
            let newCount = newMovies[year]?.count ?? 0
            let yearIndex = getYears().firstIndex(of: year) ?? 0
            
            if newCount > oldCount {
                // Add new rows
                let newIndexPaths = (oldCount..<newCount).map {
                    IndexPath(row: $0, section: yearIndex)
                }
                rowsToAdd.append(contentsOf: newIndexPaths)
            }
        }
        
        return (
            sectionsToAdd: IndexSet(addedYears.map { getYears().firstIndex(of: $0) ?? 0 }),
            sectionsToRemove: IndexSet(removedYears.map { getYears().firstIndex(of: $0) ?? 0 }),
            rowsToAdd: rowsToAdd,
            rowsToRemove: rowsToRemove
        )
    }
}

// MARK: - UITableViewDataSource
extension MoviesTableViewManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return getYears().count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let years = getYears()
        guard section < years.count else { return 0 }
        let year = years[section]
        return viewModel.movies.moviesByYear[year]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MovieTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? MovieTableViewCell else {
            return UITableViewCell()
        }
        
        if let movie = movie(at: indexPath) {
            cell.configure(with: movie, imageLoadingService: imageLoadingService)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let years = getYears()
        guard section < years.count else { return nil }
        return String(years[section])
    }
}

// MARK: - UITableViewDelegate
extension MoviesTableViewManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let movie = movie(at: indexPath) {
            delegate?.movieTableViewManager(self, didSelectMovie: movie)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        let years = getYears()
        guard section < years.count else { return headerView }
        label.text = String(years[section])
        label.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MoviesTableViewManager: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let years = getYears()
        for indexPath in indexPaths {
            guard indexPath.section < years.count else { continue }
            let year = years[indexPath.section]
            guard let moviesInYear = viewModel.movies.moviesByYear[year] else { continue }
            
            if indexPath.row >= moviesInYear.count - 3 {
                Task {
                    await viewModel.loadMorePopularMoviesIfNeeded(for: indexPath.section)
                }
                break
            }
        }
    }
}

// MARK: - Public Interface
extension MoviesTableViewManager {
    func reloadData() {
        guard let tableView = (delegate as? MoviesListViewController)?.tableView else { return }
        
        let updates = calculateTableViewUpdates(
            oldMovies: currentMoviesByYear,
            newMovies: viewModel.movies.moviesByYear
        )
        
        if updates.sectionsToAdd.isEmpty && updates.rowsToAdd.isEmpty {
            // If there are no updates, just return
            return
        }
        
        // Begin updates
        tableView.performBatchUpdates {
            if !updates.sectionsToAdd.isEmpty {
                tableView.insertSections(updates.sectionsToAdd, with: .none)
            }
            if !updates.sectionsToRemove.isEmpty {
                tableView.deleteSections(updates.sectionsToRemove, with: .none)
            }
            if !updates.rowsToAdd.isEmpty {
                tableView.insertRows(at: updates.rowsToAdd, with: .none)
            }
            if !updates.rowsToRemove.isEmpty {
                tableView.deleteRows(at: updates.rowsToRemove, with: .none)
            }
        }
        
        // Update our cached state
        currentMoviesByYear = viewModel.movies.moviesByYear
    }
    
    func reloadEverything() {
        guard let tableView = (delegate as? MoviesListViewController)?.tableView else { return }
        currentMoviesByYear.removeAll()
        tableView.reloadData()
    }
}
