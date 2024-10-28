//
//  MoviesCacheManager.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import DataRepository

actor MoviesCacheManager {
    private var cache: [FetchType: (movies: MoviesByYearDTO, page: Int)] = [:]
    private let maxCacheSize: Int
    
    init(maxCacheSize: Int = 3) {
        self.maxCacheSize = maxCacheSize
    }
    
    func setCached(_ movies: MoviesByYearDTO, for type: FetchType, page: Int) {
        if cache.count >= maxCacheSize {
            cache.removeValue(forKey: cache.keys.first!)
        }
        cache[type] = (movies: movies, page: page)
    }
    
    func getCached(for type: FetchType) -> (movies: MoviesByYearDTO, page: Int)? {
        return cache[type]
    }
    
    func clear() {
        cache.removeAll()
    }
}
