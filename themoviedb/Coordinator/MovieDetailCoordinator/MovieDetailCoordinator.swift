//
//  MovieDetailCoordinator.swift
//  themoviedb
//
//  Created by Jimmy on 04/09/2024.
//

import UIKit
import DataRepository

class MovieDetailCoordinator: Coordinator {
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let movie: MovieDTO
    
    init(navigationController: UINavigationController, movie: MovieDTO) {
        self.navigationController = navigationController
        self.movie = movie
    }
    
    func start() {
        let imageLoadingService = DependencyContainer.shared.makeImageCache()
        let detailVC = DependencyContainer.shared.makeMovieDetailsViewController(movie: movie, coordinator: self, imageLoadingService: imageLoadingService)
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func childDidFinish(_ child: Coordinator?) {
        // Implementation not needed for this coordinator as it doesn't have child coordinators
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
    
    func pop() {
        navigationController.popViewController(animated: true)
    }
}
