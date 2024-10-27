//
//  MemoryCache.swift
//  themoviedb
//
//  Created by Jimmy on 06/09/2024.
//

import Foundation
import UIKit

final class MemoryCache: MemoryCacheService {
    private let cache = NSCache<NSString, UIImage>()
    
    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func cache(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
