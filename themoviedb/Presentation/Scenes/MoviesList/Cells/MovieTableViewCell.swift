//
//  MovieTableViewCell.swift
//  themoviedb
//
//  Created by Jimmy on 03/09/2024.
//

import UIKit
import SwiftUI
import DataRepository

class MovieTableViewCell: UITableViewCell {
    static let reuseIdentifier = "MovieTableViewCell"
    
    private var hostingController: UIHostingController<MovieCellView>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHostingController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHostingController() {
        hostingController = UIHostingController(rootView: DependencyContainer.shared.makeMovieCellView(movie: nil, imageLoadingService: nil))
        hostingController?.view.backgroundColor = .clear
        
        guard let hostingView = hostingController?.view else { return }
        contentView.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(with movie: MovieDTO, imageLoadingService: ImageCacheService) {
        hostingController?.rootView = DependencyContainer.shared.makeMovieCellView(movie: movie, imageLoadingService: imageLoadingService)
    }
    
}
