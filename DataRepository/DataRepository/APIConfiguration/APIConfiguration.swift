//
//  APIConfiguration.swift
//  DataRepository
//
//  Created by Jimmy on 27/10/2024.
//


final class APIConfiguration: APIConfigurationProtocol {
    // MARK: - Singleton
    static let shared = APIConfiguration()
    
    private init() {
        setupEnvironment()
    }
    
    // MARK: - Environment Keys
    private enum EnvironmentKey {
        static let bearerToken = "TMDB_BEARER_TOKEN"
        static let baseURL = "TMDB_BASE_URL"
        static let imageBaseURL = "TMDB_IMAGE_BASE_URL"
        
        // Default values
        static let defaultBaseURL = "https://api.themoviedb.org/3"
        static let defaultImageBaseURL = "https://image.tmdb.org/t/p"
    }
    
    // MARK: - Properties
    private var environment: [String: String] = [:]
    
    var bearerToken: String {
        guard let token = environment[EnvironmentKey.bearerToken] else {
            fatalError("Bearer token not found. Please set \(EnvironmentKey.bearerToken) environment variable")
        }
        return token
    }
    
    var baseURL: String {
        environment[EnvironmentKey.baseURL] ?? EnvironmentKey.defaultBaseURL
    }
    
    var imageBaseURL: String {
        environment[EnvironmentKey.imageBaseURL] ?? EnvironmentKey.defaultImageBaseURL
    }
}

// MARK: - Environment Setup
private extension APIConfiguration {
    func setupEnvironment() {
        #if DEBUG
        setupDevelopmentEnvironment()
        #else
        setupProductionEnvironment()
        #endif
        
        validateConfiguration()
    }
    
    func setupDevelopmentEnvironment() {
        // Load from environment variables first
        environment = ProcessInfo.processInfo.environment
        
        // If bearer token is not set in environment variables, try to load from configuration file
        if environment[EnvironmentKey.bearerToken] == nil {
            loadDevelopmentConfiguration()
        }
    }
    
    func setupProductionEnvironment() {
        // In production, we strictly use environment variables
        environment = ProcessInfo.processInfo.environment
    }
    
    func loadDevelopmentConfiguration() {
        // Try to load from Configuration.json in the bundle
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "json"),
           let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
           let config = try? JSONDecoder().decode([String: String].self, from: data) {
            environment.merge(config) { current, _ in current }
        }
    }
    
    func validateConfiguration() {
        let requiredKeys = [EnvironmentKey.bearerToken]
        
        for key in requiredKeys {
            guard environment[key] != nil else {
                #if DEBUG
                print("⚠️ WARNING: Required environment variable '\(key)' is not set")
                #else
                fatalError("Required environment variable '\(key)' is not set")
                #endif
                continue
            }
        }
    }
}

// MARK: - Environment Helper
extension APIConfiguration {
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #elseif STAGING
            return .staging
            #else
            return .production
            #endif
        }
    }
    
    var currentEnvironment: Environment {
        Environment.current
    }
}

// MARK: - Configuration Access
extension APIConfiguration {
    func getValue(for key: String, default defaultValue: String? = nil) -> String {
        if let value = environment[key] {
            return value
        }
        
        if let defaultValue = defaultValue {
            return defaultValue
        }
        
        #if DEBUG
        print("⚠️ WARNING: No value found for key '\(key)'")
        #endif
        
        return ""
    }
    
    func setValue(_ value: String, for key: String) {
        #if DEBUG
        environment[key] = value
        #endif
    }
}

// MARK: - Image URL Builder
extension APIConfiguration {
    enum ImageSize: String {
        case small = "w185"
        case medium = "w342"
        case large = "w500"
        case original = "original"
    }
    
    func imageURL(path: String, size: ImageSize) -> URL? {
        URL(string: "\(imageBaseURL)/\(size.rawValue)\(path)")
    }
}