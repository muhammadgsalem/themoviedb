//
//  MoviesCoordinator.swift
//  themoviedb
//
//  Created by Jimmy on 04/09/2024.
//

import UIKit
import DataRepository

class MoviesCoordinator: @preconcurrency Coordinator {
    
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor func start() {
        let imageLoadingService = DependencyContainer.shared.makeImageCache()
        let moviesVC = DependencyContainer.shared.makeMoviesListViewController(coordinator: self, imageLoadingService: imageLoadingService)
        navigationController.pushViewController(moviesVC, animated: false)
    }
    
    func showCharacterDetails(_ character: Character) {
        let detailCoordinator = MovieDetailCoordinator(navigationController: navigationController, character: character)
        detailCoordinator.parentCoordinator = self
        childCoordinators.append(detailCoordinator)
        detailCoordinator.start()
    }
    
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}
