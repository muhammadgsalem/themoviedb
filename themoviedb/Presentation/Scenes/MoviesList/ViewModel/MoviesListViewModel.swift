//
//  MoviesListViewModel.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//
//
//  MoviesListViewModel.swift
//  themoviedb
//
//  Created by Jimmy on 28/10/2024.
//

import BusinessLayer
import DataRepository
import Foundation

@MainActor
final class MoviesListViewModel: MoviesListViewModelProtocol {
    private let fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol
    private let searchMoviesUseCase: SearchMoviesUseCaseProtocol
    private let retryPolicy: RetryPolicy
    private let cacheManager: MoviesCacheManager
    private let dataManager: MoviesDataManager
    private let paginationState: PaginationState
    private var currentFetchType: FetchType = .popular
    private var lastFetchTask: Task<Void, Never>?
    
    weak var delegate: MoviesListViewModelDelegate?
    
    private(set) var movies: MoviesByYearDTO = .empty {
        didSet {
            state = .loaded(movies)
        }
    }
    
    var canLoadMorePages: Bool { paginationState.canLoadMorePages }
    
    private var state: ViewState = .idle {
        didSet {
            delegate?.viewModelDidUpdateState(self, state: state)
        }
    }
    
    init(fetchPopularMoviesUseCase: FetchPopularMoviesUseCaseProtocol,
         searchMoviesUseCase: SearchMoviesUseCaseProtocol,
         retryPolicy: RetryPolicy = DefaultRetryPolicy(),
         cacheManager: MoviesCacheManager = MoviesCacheManager(),
         dataManager: MoviesDataManager = MoviesDataManager())
    {
        self.fetchPopularMoviesUseCase = fetchPopularMoviesUseCase
        self.searchMoviesUseCase = searchMoviesUseCase
        self.retryPolicy = retryPolicy
        self.cacheManager = cacheManager
        self.dataManager = dataManager
        self.paginationState = PaginationState()
    }
    
    func loadMoreMoviesIfNeeded(for index: Int) {
        guard canLoadMorePages else { return }
        
        Task { [weak self] in
            guard let self = self else { return }
            switch currentFetchType {
            case .popular:
                await loadPopularMovies()
            case .search(let query):
                await searchMovies(query: query)
            }
        }
    }
    
    func searchMovies(query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedQuery.isEmpty else {
            await loadPopularMovies()
            return
        }
        
        await fetchMovies(type: .search(trimmedQuery)) { page in
            try await self.searchMoviesUseCase.execute(query: trimmedQuery, page: page)
        }
    }
    
    func loadPopularMovies() async {
        await fetchMovies(type: .popular) { page in
            try await self.fetchPopularMoviesUseCase.execute(page: page)
        }
    }
    
    private func fetchMovies(type: FetchType,
                             operation: @escaping (Int) async throws -> MoviesByYearDTO) async
    {
        lastFetchTask?.cancel()
        
        if currentFetchType != type {
            resetPagination()
            currentFetchType = type
        }
        
        if paginationState.currentPage == 1,
           let cached = await cacheManager.getCached(for: type)
        {
            await dataManager.update(with: cached.movies, isFirstPage: true)
            movies = await dataManager.movies
            paginationState.updateForNextPage(totalPages: cached.movies.totalPages)
            return
        }
        
        if paginationState.currentPage == 1 {
            state = .loading
        }
        
        do {
            let result = try await retryPolicy.execute {
                try await operation(paginationState.currentPage)
            }
            
            if result.totalResults == 0 {
                await dataManager.reset()
                movies = .empty
                paginationState.reset()
                return
            }
            
            await dataManager.update(with: result,
                                     isFirstPage: paginationState.currentPage == 1)
            
            if paginationState.currentPage == 1 {
                await cacheManager.setCached(result,
                                             for: type,
                                             page: paginationState.currentPage)
            }
            
            movies = await dataManager.movies
            paginationState.updateForNextPage(totalPages: result.totalPages)
            
        } catch {
            if paginationState.currentPage == 1 {
                await dataManager.reset()
                movies = .empty
            }
            paginationState.reset()
            state = .error(MovieError.from(error))
        }
    }
    
    func retryLastOperation() async {
        state = .loading
        paginationState.setFetching(false)
        let pageToRetry = max(1, paginationState.currentPage - 1)
        paginationState.reset()
        paginationState.setPage(pageToRetry)
        
        switch currentFetchType {
        case .popular:
            await loadPopularMovies()
        case .search(let query):
            let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedQuery.isEmpty {
                await searchMovies(query: trimmedQuery)
            } else {
                currentFetchType = .popular
                await loadPopularMovies()
            }
        }
    }
    
    func resetPagination() {
        lastFetchTask?.cancel()
        paginationState.reset()
        Task {
            await dataManager.reset()
            movies = .empty
        }
        state = .idle
    }
}

// MARK: - MovieError

enum MovieError: LocalizedError {
    case network(String)
    case parsing
    case unknown

    static func from(_ error: Error) -> MovieError {
        switch error {
        case let networkError as URLError:
            return .network(networkError.localizedDescription)
        case is DecodingError:
            return .parsing
        default:
            return .unknown
        }
    }

    var errorDescription: String? {
        switch self {
        case .network(let message):
            return "Network error: \(message)"
        case .parsing:
            return "Failed to parse movie data"
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

// MARK: - RetryPolicy

protocol RetryPolicy {
    func execute<T>(_ operation: () async throws -> T) async throws -> T
}

struct DefaultRetryPolicy: RetryPolicy {
    private let maxAttempts: Int
    private let baseDelay: TimeInterval
    

    private var nanosPerSecond: UInt64 { 1_000_000_000 }
    
    private func getDelayTime(forAttempt attempt: Int) -> UInt64 {
        let exponentialDelay = pow(2.0, Double(attempt)) * baseDelay
        return UInt64(exponentialDelay * Double(nanosPerSecond))
    }
    
    init(maxAttempts: Int = 3, baseDelay: TimeInterval = 1.0) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
    }
    
    func execute<T>(_ operation: () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 0 ..< maxAttempts {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                if attempt < maxAttempts - 1 {
                    try await Task.sleep(nanoseconds: getDelayTime(forAttempt: attempt))
                }
            }
        }
        
        throw lastError ?? MovieError.unknown
    }
}
