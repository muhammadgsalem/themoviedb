//
//  DefaultDependencyContainer.swift
//  themoviedb
//
//  Created by Jimmy on 03/09/2024.
//

import APIGate
import BusinessLayer
import DataRepository
import Foundation

final class DependencyContainer: @preconcurrency DependencyContainerProtocol {
    static let shared = DependencyContainer()
    
    private let apiGateDIContainer: APIGateDIContainer
    private let dataRepositoryDIContainer: DataRepositoryDIContainer
    private let businessLayerDIContainer: BusinessLayerDIContainer
    
    private init(
        apiGateDIContainer: APIGateDIContainer = .shared,
        dataRepositoryDIContainer: DataRepositoryDIContainer = .shared,
        businessLayerDIContainer: BusinessLayerDIContainer = .shared
    ) {
        self.apiGateDIContainer = apiGateDIContainer
        self.dataRepositoryDIContainer = dataRepositoryDIContainer
        self.businessLayerDIContainer = businessLayerDIContainer
    }
    
    @MainActor func makeMoviesListViewModel() -> MoviesListViewModelProtocol {
        MoviesListViewModel(fetchPopularMoviesUseCase: businessLayerDIContainer.makeFetchPopularMoviesUseCase(),searchMoviesUseCase: businessLayerDIContainer.makeSearchMoviesUseCase())
    }
    
    @MainActor func makeMoviesListViewController(coordinator: MoviesCoordinator, imageLoadingService: ImageCacheService) -> MoviesListViewController {
        let viewModel = makeMoviesListViewModel()
        return MoviesListViewController(coordinator: coordinator,
                                        viewModel: viewModel,
                                        imageLoadingService: imageLoadingService)
    }
    

    
    func makeMovieCellView(movie: MovieDTO?, imageLoadingService: ImageCacheService?) -> MovieCellView {
        MovieCellView(movie: movie, imageLoadingService: imageLoadingService)
    }
    
    func makeMovieDetailsViewController(movie: MovieDTO, coordinator: MovieDetailCoordinator, imageLoadingService: ImageCacheService) -> MovieDetailsViewController {
        let imageLoadingService = makeImageCache()
        return MovieDetailsViewController(movie: movie,
                                              coordinator: coordinator,
                                              imageLoadingService: imageLoadingService)
    }
    
    func makeMovieDetailsView(movie: MovieDTO, imageLoadingService: ImageCacheService, onBackActionSelected: @escaping () -> Void) -> MovieDetailsView {
        MovieDetailsView(movie: movie,
                             onBackActionSelected: onBackActionSelected,
                             imageLoadingService: imageLoadingService)
    }
    
    func makeImageCache() -> ImageCacheService {
        ImageCache(memoryCache: makeMemoryCache(), diskCache: makeDiskCache())
    }
    
    func makeMemoryCache() -> MemoryCacheService {
        MemoryCache()
    }
    
    func makeDiskCache() -> DiskCacheService {
        DiskCache()
    }
}
