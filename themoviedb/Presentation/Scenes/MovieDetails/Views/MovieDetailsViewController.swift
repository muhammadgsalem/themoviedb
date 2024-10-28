//
//  MovieDetailsViewController.swift
//  themoviedb
//
//  Created by Jimmy on 27/10/2024.
//

import DataRepository
import SwiftUI
import UIKit

class MovieDetailsViewController: UIViewController {
    weak var coordinator: MovieDetailCoordinator?
    private let movie: MovieDTO
    private let imageLoadingService: ImageCacheService
    
    init(movie: MovieDTO, coordinator: MovieDetailCoordinator, imageLoadingService: ImageCacheService) {
        self.movie = movie
        self.coordinator = coordinator
        self.imageLoadingService = imageLoadingService
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            coordinator?.finish()
        }
    }
    
    private func setupSwiftUIView() {
        let movieDetailsView = DependencyContainer.shared.makeMovieDetailsView(
                    movie: movie,
                    imageLoadingService: imageLoadingService,
                    onBackActionSelected: { [weak self] in
                        self?.coordinator?.pop()
                    }
                )
        
        let hostingController = UIHostingController(rootView: movieDetailsView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
