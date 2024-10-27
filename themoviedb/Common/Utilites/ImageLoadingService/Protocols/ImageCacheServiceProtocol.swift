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
}
