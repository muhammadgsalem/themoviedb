//
//  ImageLoadingManager.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import UIKit

actor ImageLoadingManager {
    private var activeTasks: [URL: Task<UIImage, Error>] = [:]
    
    func task(for url: URL) -> Task<UIImage, Error>? {
        return activeTasks[url]
    }
    
    func addTask(_ task: Task<UIImage, Error>, for url: URL) {
        activeTasks[url] = task
    }
    
    func removeTask(for url: URL) {
        activeTasks[url] = nil
    }
    
    func cancelAll() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
    }
    
    func cancelTask(for url: URL) {
        activeTasks[url]?.cancel()
        activeTasks[url] = nil
    }
}
