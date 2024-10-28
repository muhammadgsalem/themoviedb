//
//  DiskCache.swift
//  themoviedb
//
//  Created by Jimmy on 06/09/2024.
//

import Foundation
import UIKit

final class DiskCache: DiskCacheService {
    private let fileManager = FileManager.default
    private let cachesDirectory: URL
    
    init() {
        cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func image(for key: String) -> UIImage? {
        let filePath = cachesDirectory.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key)
        guard let data = try? Data(contentsOf: filePath) else { return nil }
        return UIImage(data: data)
    }
    
    func cache(_ image: UIImage, for key: String) {
        let filePath = cachesDirectory.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key)
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: filePath)
        }
    }
    
    func clearCache() {
        let cacheContents = try? fileManager.contentsOfDirectory(at: cachesDirectory, includingPropertiesForKeys: nil, options: [])
        cacheContents?.forEach { url in
            try? fileManager.removeItem(at: url)
        }
    }
}
