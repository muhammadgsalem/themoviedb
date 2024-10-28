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
    private let session: URLSession
    private let loadingManager = ImageLoadingManager()
    
    init(memoryCache: MemoryCacheService,
         diskCache: DiskCacheService,
         session: URLSession = .shared) {
        self.memoryCache = memoryCache
        self.diskCache = diskCache
        self.session = session
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
        Task {
            await loadingManager.cancelAll()
        }
    }
    
    func loadImage(for url: URL) async throws -> UIImage {
        if let cachedImage = image(for: url) {
            return cachedImage
        }
        
        return try await withTaskCancellationHandler(operation: {
            try await startImageLoad(for: url)
        }, onCancel: {
            Task {
                await self.loadingManager.cancelTask(for: url)
            }
        })
    }
    
    private func startImageLoad(for url: URL) async throws -> UIImage {
        if let existingTask = await loadingManager.task(for: url) {
            return try await existingTask.value
        }
        
        let task = Task<UIImage, Error> {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ImageCache",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])
            }
            
            self.cache(image, for: url)
            return image
        }
        
        await loadingManager.addTask(task, for: url)
        
        do {
            let image = try await task.value
            await loadingManager.removeTask(for: url)
            return image
        } catch {
            await loadingManager.removeTask(for: url)
            throw error
        }
    }
    
    func cancelLoad(for url: URL) {
        Task {
            await loadingManager.cancelTask(for: url)
        }
    }
}
