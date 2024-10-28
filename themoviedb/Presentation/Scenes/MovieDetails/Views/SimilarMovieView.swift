//
//  SimilarMovieView.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import SwiftUI
import DataRepository
struct SimilarMovieView: View {
    let movie: MovieDTO
    let imageLoadingService: ImageCacheService
    let cast: CastDTO?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Movie poster
            if let url = movie.posterURL {
                MovieAsyncImage(url: url, imageCache: imageLoadingService)
                    .frame(width: 200, height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Title
            Text(movie.title)
                .font(.headline)
                .lineLimit(1)
            
            // Metadata
            MovieMetadataView(
                year: movie.releaseYear,
                rating: movie.formattedRating,
                voteCount: movie.voteCount,
                font: .caption
            )
            
            // Cast section
            if let cast = cast {
                MovieCastView(cast: cast)
            }
        }
        .frame(width: 200)
    }
}
