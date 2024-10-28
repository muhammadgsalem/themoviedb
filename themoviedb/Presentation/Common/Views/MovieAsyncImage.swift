//
//  MovieAsyncImage.swift
//  themoviedb
//
//  Created by Jimmy on 05/09/2024.
//

import SwiftUI

struct MovieAsyncImage: View {
    let url: URL
    @State private var image: UIImage?
    let imageCache: ImageCacheService
    
    init(url: URL, imageCache: ImageCacheService = DependencyContainer.shared.makeImageCache()) {
        self.url = url
        self.imageCache = imageCache
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView()
            }
        }
        .onAppear(perform: loadImage)
    }
    
    private func loadImage() {
        if let cachedImage = imageCache.image(for: url) {
            self.image = cachedImage
        } else {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let downloadedImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = downloadedImage
                        self.imageCache.cache(downloadedImage, for: url)
                    }
                }
            }.resume()
        }
    }
}
