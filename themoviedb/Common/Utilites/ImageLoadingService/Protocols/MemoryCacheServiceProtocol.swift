//
//  MemoryCacheServiceProtocol.swift
//  themoviedb
//
//  Created by Jimmy on 06/09/2024.
//

import Foundation
import UIKit

protocol MemoryCacheService {
    func image(for key: String) -> UIImage?
    func cache(_ image: UIImage, for key: String)
    func clearCache()
}
