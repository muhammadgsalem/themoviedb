//
//  PaginationState.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//


final class PaginationState {
    private(set) var currentPage = 1
    private(set) var hasMorePages = true
    private(set) var isFetching = false
    
    var canLoadMorePages: Bool {
        !isFetching && hasMorePages
    }
    
    func reset() {
        currentPage = 1
        hasMorePages = true
        isFetching = false
    }
    
    func updateForNextPage(totalPages: Int) {
        hasMorePages = totalPages > currentPage
        currentPage += 1
        isFetching = false
    }
    
    func setFetching(_ fetching: Bool) {
        isFetching = fetching
    }
    
    func setPage(_ page: Int) {
        currentPage = page
    }
}
