//
//  ImageCache.swift
//  themoviedb
//
//  Created by Jimmy on 05/09/2024.
//

import UIKit

final class ImageCache: ImageCacheService {
    private let memoryCache: MemoryCacheService
    private let diskCache: DiskCacheService
    
    init(memoryCache: MemoryCacheService, diskCache: DiskCacheService) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
    }
    
    func image(for url: URL) -> UIImage? {
        let key = url.absoluteString
        if let cachedImage = memoryCache.image(for: key) {
            return cachedImage
        }
        if let diskImage = diskCache.image(for: key) {
            memoryCache.cache(diskImage, for: key)
            return diskImage
        }
        return nil
    }
    
    func cache(_ image: UIImage, for url: URL) {
        let key = url.absoluteString
        memoryCache.cache(image, for: key)
        diskCache.cache(image, for: key)
    }
    
    func clearCache() {
        memoryCache.clearCache()
        diskCache.clearCache()
    }
}
