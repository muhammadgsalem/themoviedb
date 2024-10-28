//
//  MovieDetailsViewController.swift
//  themoviedb
//
//  Created by Jimmy on 27/10/2024.
//

import UIKit
import SwiftUI
import DataRepository

class MovieDetailsViewController: UIViewController {
    weak var coordinator: MovieDetailCoordinator?
    private let movie: MovieDTO
    private let imageLoadingService: ImageCacheService
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }




    init(movie: MovieDTO, coordinator: MovieDetailCoordinator, imageLoadingService: ImageCacheService) {
        self.movie = movie
        self.coordinator = coordinator
        self.imageLoadingService = imageLoadingService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
