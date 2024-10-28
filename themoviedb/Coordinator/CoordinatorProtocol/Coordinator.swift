//
//  Coordinator.swift
//  themoviedb
//
//  Created by Jimmy on 03/09/2024.
//

import UIKit

protocol Coordinator: AnyObject {
    var parentCoordinator: Coordinator? { get set }
    var navigationController: UINavigationController { get }
    var childCoordinators: [Coordinator] { get set }
    
    func start()
    func finish()
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {
    func childDidFinish(_ child: Coordinator?) {
        // Default implementation
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
}
