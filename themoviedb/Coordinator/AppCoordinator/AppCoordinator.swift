//
//  AppCoordinator.swift
//  themoviedb
//
//  Created by Jimmy on 03/09/2024.
//

import UIKit

class AppCoordinator: @preconcurrency Coordinator {
    weak var parentCoordinator: Coordinator?
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    @MainActor func start() {
        showMoviesList()
    }
    
    @MainActor private func showMoviesList() {
        let charactersCoordinator = MoviesCoordinator(navigationController: navigationController)
        charactersCoordinator.parentCoordinator = self
        childCoordinators.append(charactersCoordinator)
        charactersCoordinator.start()
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
        // AppCoordinator is the root coordinator, so it doesn't need to notify any parent
        // However, we can use this method to perform any cleanup if needed
        childCoordinators.removeAll()
    }
}
