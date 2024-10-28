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
        HStack(alignment: .top, spacing: 10) {
            if let movie = movie, let imageLoadingService = imageLoadingService, let url = movie.posterURL {
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
        .padding(10)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.vertical, 4)
        .id(movie?.id)
    }
    

}

struct CharacterCellView_Preview: PreviewProvider {
    static var previews: some View {
        MovieCellView(movie: nil, imageLoadingService: nil)
            .previewLayout(.sizeThatFits)
            .padding()
            .previewDisplayName("Movie Cell")
        
    }
}

