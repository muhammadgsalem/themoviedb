//
//  MovieCellView.swift
//  themoviedb
//
//  Created by Jimmy on 03/09/2024.
//

import DataRepository
import SwiftUI

struct MovieCellView: View {
    let movie: MovieDTO?
    let imageLoadingService: ImageCacheService?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 10) {
                if let movie = movie,
                   let imageLoadingService = imageLoadingService,
                   let url = movie.posterURL {
                    MovieImageView(imageURL: url, imageLoadingService: imageLoadingService)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    if let title = movie?.title {
                        Text(title)
                            .font(.headline)
                            .bold()
                    }
                    
                    if let overview = movie?.overview {
                        Text(overview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .frame(height: 120)
            .padding(2)
            .padding(.horizontal, 5)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.horizontal, 5) 
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.vertical, 4)
        .id(movie?.id)
    }
}

struct MovieCellView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            MovieCellView(movie: nil, imageLoadingService: nil)
            MovieCellView(movie: nil, imageLoadingService: nil)
            MovieCellView(movie: nil, imageLoadingService: nil)
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .previewDisplayName("Movie Cell")
    }
}
