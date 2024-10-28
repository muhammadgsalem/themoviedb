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
    var tableView: UITableView { get }
}

@MainActor
final class MoviesTableViewManager: NSObject {
    // MARK: - Properties
    private let viewModel: MoviesListViewModelProtocol
    private let imageLoadingService: ImageCacheService
    private var currentMoviesByYear: [Int: [MovieDTO]] = [:]
    private var isPaginationEnabled = true
    private var isUpdating = false
    private let debounceInterval: TimeInterval = 0.5
    private var lastPaginationRequestTime: TimeInterval = 0
    weak var delegate: MoviesTableViewManagerDelegate?
    
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
    
    private func isAppendingData(oldMovies: [Int: [MovieDTO]], newMovies: [Int: [MovieDTO]]) -> Bool {
        for (year, oldItems) in oldMovies {
            guard let newItems = newMovies[year],
                  oldItems.count <= newItems.count,
                  zip(oldItems, newItems.prefix(oldItems.count))
                    .allSatisfy({ $0.id == $1.id })
            else { return false }
        }
        return true
    }
    
    private func shouldTriggerPagination() -> Bool {
        guard isPaginationEnabled,
              !isUpdating,
              viewModel.canLoadMorePages else { return false }
        
        let currentTime = CACurrentMediaTime()
        if currentTime - lastPaginationRequestTime < debounceInterval {
            return false
        }
        
        lastPaginationRequestTime = currentTime
        return true
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldTriggerPagination() else { return }
        
        let bottomEdge = scrollView.contentOffset.y + scrollView.bounds.height
        let threshold = scrollView.contentSize.height - 1000 // Load more when within 1000 points of bottom
        
        if bottomEdge >= threshold {
            let years = getYears()
            guard !years.isEmpty else { return }
            
            isPaginationEnabled = false
            Task { [weak self] in
                guard let self = self else { return }
                await viewModel.loadMoreMoviesIfNeeded(for: years.count - 1)
                isPaginationEnabled = true
            }
        }
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension MoviesTableViewManager: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard shouldTriggerPagination() else { return }
        
        let years = getYears()
        
        // Find the highest section and row being prefetched
        guard let maxIndexPath = indexPaths.max(by: { $0.section == $1.section ? $0.row < $1.row : $0.section < $1.section }),
              maxIndexPath.section < years.count else { return }
        
        // Get total items in the current section
        let year = years[maxIndexPath.section]
        let itemsInSection = viewModel.movies.moviesByYear[year]?.count ?? 0
        
        // Check if we're near the end of content
        let isNearEndOfSection = maxIndexPath.row >= itemsInSection - 5
        let isInLastSections = maxIndexPath.section >= years.count - 2
        
        if (isNearEndOfSection && isInLastSections) || years.isEmpty {
            isPaginationEnabled = false
            Task { [weak self] in
                guard let self = self else { return }
                await viewModel.loadMoreMoviesIfNeeded(for: maxIndexPath.section)
                isPaginationEnabled = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // Implement if needed for cleanup
    }
}

// MARK: - Public Interface
extension MoviesTableViewManager {
    func reloadData() {
        guard let tableView = delegate?.tableView else { return }
        
        let oldMovies = currentMoviesByYear
        let newMovies = viewModel.movies.moviesByYear
        
        // First load or complete refresh
        if oldMovies.isEmpty {
            currentMoviesByYear = newMovies
            tableView.reloadData()
            return
        }
        
        // Save scroll position information
        let visibleIndexPaths = tableView.indexPathsForVisibleRows ?? []
        var referenceIndexPath: IndexPath?
        var referenceOffset: CGFloat = 0
        
        if let firstVisible = visibleIndexPaths.first {
            referenceIndexPath = firstVisible
            let cellRect = tableView.rectForRow(at: firstVisible)
            referenceOffset = tableView.contentOffset.y - cellRect.minY
        }
        
        isUpdating = true
        
        // Handle incremental updates vs full reload
        if isAppendingData(oldMovies: oldMovies, newMovies: newMovies) {
            performIncrementalUpdate(tableView: tableView,
                                   oldMovies: oldMovies,
                                   newMovies: newMovies,
                                   referenceIndexPath: referenceIndexPath,
                                   referenceOffset: referenceOffset)
        } else {
            performFullReload(tableView: tableView, newMovies: newMovies)
        }
        
        isUpdating = false
        isPaginationEnabled = true
    }
    
    private func performIncrementalUpdate(tableView: UITableView,
                                        oldMovies: [Int: [MovieDTO]],
                                        newMovies: [Int: [MovieDTO]],
                                        referenceIndexPath: IndexPath?,
                                        referenceOffset: CGFloat) {
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            
            // Calculate and apply updates
            let oldYears = Set(oldMovies.keys)
            let newYears = Set(newMovies.keys)
            
            // Handle new sections
            let sectionsToAdd = newYears.subtracting(oldYears)
            if !sectionsToAdd.isEmpty {
                let newSectionIndexes = sectionsToAdd.compactMap { year in
                    getYears().firstIndex(of: year)
                }
                tableView.insertSections(IndexSet(newSectionIndexes), with: .none)
            }
            
            // Handle new rows in existing sections
            for year in oldYears {
                let oldCount = oldMovies[year]?.count ?? 0
                let newCount = newMovies[year]?.count ?? 0
                
                if newCount > oldCount {
                    guard let sectionIndex = getYears().firstIndex(of: year) else { continue }
                    let indexPaths = (oldCount..<newCount).map {
                        IndexPath(row: $0, section: sectionIndex)
                    }
                    tableView.insertRows(at: indexPaths, with: .none)
                }
            }
            
            currentMoviesByYear = newMovies
            tableView.endUpdates()
        }
        
        // Restore scroll position
        restoreScrollPosition(in: tableView,
                            referenceIndexPath: referenceIndexPath,
                            referenceOffset: referenceOffset)
    }
    
    private func performFullReload(tableView: UITableView, newMovies: [Int: [MovieDTO]]) {
        currentMoviesByYear = newMovies
        tableView.reloadData()
    }
    
    private func restoreScrollPosition(in tableView: UITableView,
                                     referenceIndexPath: IndexPath?,
                                     referenceOffset: CGFloat) {
        guard let referenceIndexPath = referenceIndexPath else { return }
        
        DispatchQueue.main.async {
            
            // Validate reference index path
            guard referenceIndexPath.section < tableView.numberOfSections,
                  referenceIndexPath.row < tableView.numberOfRows(inSection: referenceIndexPath.section)
            else { return }
            
            let updatedCellRect = tableView.rectForRow(at: referenceIndexPath)
            let newOffset = updatedCellRect.minY + referenceOffset
            
            // Ensure offset is within bounds
            let maxOffset = max(0, tableView.contentSize.height - tableView.bounds.height)
            let boundedOffset = min(max(0, newOffset), maxOffset)
            
            // Apply new offset without animation
            tableView.setContentOffset(CGPoint(x: 0, y: boundedOffset), animated: false)
        }
    }
    
    func reloadEverything() {
        guard let tableView = delegate?.tableView else { return }
        currentMoviesByYear.removeAll()
        tableView.reloadData()
    }
}
