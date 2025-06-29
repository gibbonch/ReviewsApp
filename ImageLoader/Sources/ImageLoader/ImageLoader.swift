import UIKit

public final class ImageLoader {
    
    public enum Error: Swift.Error {
        case invalidURL
        case decodingFailed
        case networkError(Swift.Error)
    }
    
    public static let shared = ImageLoader(configuration: .default)
    
    private let configuration: ImageLoaderConfiguration
    private let memoryCache: MemoryCache
    private let session: URLSession
    private let semaphore: DispatchSemaphore
    
    public init(configuration: ImageLoaderConfiguration) {
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.requestTimeout
        config.timeoutIntervalForResource = configuration.requestTimeout
        
        self.session = URLSession(configuration: config)
        self.memoryCache = MemoryCache(capacity: configuration.memoryCapacity)
        self.semaphore = DispatchSemaphore(value: configuration.maximumConcurrentRequests)
    }
    
}

// MARK: - Public

public extension ImageLoader {
    
    @discardableResult
    func loadImage(from url: URL,
                   cacheType: CacheType,
                   completion: @escaping (Result<UIImage, Error>) -> Void) -> URLSessionDataTask? {
        
        let key = url.absoluteString
        
        if let image = loadFromCache(for: key, cacheType: cacheType) {
            completion(.success(image))
            return nil
        }
        
        semaphore.wait()
        
        let task = session.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.semaphore.signal() }
            
            if let error = error as? URLError, error.code == .cancelled {
                return
            }
            
            if let error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let data, let image = UIImage(data: data) else {
                completion(.failure(.decodingFailed))
                return
            }
            
            self?.saveToCache(for: key, cacheType: cacheType, image: image)
            completion(.success(image))
        }
        
        task.resume()
        return task
    }
    
    func clearCache(type: CacheType) {
        switch type {
        case .memory:
            memoryCache.clearAll()
        case .disk:
            break
        }
    }
    
}

// MARK: - Private

private extension ImageLoader {
    func loadFromCache(for key: String, cacheType: CacheType) -> UIImage? {
        switch cacheType {
        case .memory:
            return memoryCache.image(forKey: key)
        case .disk:
            // Disk cache not implemented
            return nil
        }
    }
    
    func saveToCache(for key: String, cacheType: CacheType, image: UIImage) {
        switch cacheType {
        case .memory:
            memoryCache.setImage(image, forKey: key)
        case .disk:
            // Disk cache not implemented
            return
        }
    }
    
}
