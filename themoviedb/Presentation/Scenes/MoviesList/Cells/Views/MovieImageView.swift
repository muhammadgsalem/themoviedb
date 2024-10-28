//
//  MovieImageView.swift
//  themoviedb
//
//  Created by Jimmy on 05/09/2024.
//

import SwiftUI

struct MovieImageView: View {
    let imageURL: URL
    let imageLoadingService: ImageCacheService
    var body: some View {
        MovieAsyncImage(url: imageURL, imageCache: imageLoadingService)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct MovieImageView_Previews: PreviewProvider {
    static var previews: some View {
        MovieImageView(imageURL: URL(string: "https://example.com/image.jpg")!, imageLoadingService: DependencyContainer.shared.makeImageCache())
    }
}
