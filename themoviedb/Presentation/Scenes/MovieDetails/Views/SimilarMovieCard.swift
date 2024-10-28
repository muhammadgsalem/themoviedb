//
//  SimilarMovieCard.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import SwiftUI
import DataRepository

struct SimilarMovieCard: View {
    let movie: MovieDTO
    let imageLoadingService: ImageCacheService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let url = movie.posterURL {
                MovieAsyncImage(url: url, imageCache: imageLoadingService)
                    .frame(width: 120, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(String(movie.releaseYear))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 120)
    }
}
