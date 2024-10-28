//
//  ImageCacheServiceProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 06/09/2024.
//

import Foundation
import UIKit

protocol ImageCacheService {
    func image(for url: URL) -> UIImage?
    func cache(_ image: UIImage, for url: URL)
    func clearCache()
    func loadImage(for url: URL) async throws -> UIImage
    func cancelLoad(for url: URL)
}
