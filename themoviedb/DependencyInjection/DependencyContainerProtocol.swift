//
//  DependencyContainerProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 04/09/2024.
//

import Foundation
import DataRepository

protocol DependencyContainerProtocol {
    
    
    func makeMoviesListViewModel() -> MoviesListViewModelProtocol
    func makeMoviesListViewController(coordinator: MoviesCoordinator, imageLoadingService: ImageCacheService) -> MoviesListViewController
    func makeMovieCellView(movie: MovieDTO?, imageLoadingService: ImageCacheService?) -> MovieCellView

    
    func makeMovieDetailsViewController(movie: MovieDTO, coordinator: MovieDetailCoordinator, imageLoadingService: ImageCacheService) -> MovieDetailsViewController
    func makeMovieDetailsView(movie: MovieDTO, imageLoadingService: ImageCacheService, onBackActionSelected: @escaping () -> Void) -> MovieDetailsView
    
    
    
    func makeImageCache() -> ImageCacheService
    func makeMemoryCache() -> MemoryCacheService
    func makeDiskCache() -> DiskCacheService
    
}
