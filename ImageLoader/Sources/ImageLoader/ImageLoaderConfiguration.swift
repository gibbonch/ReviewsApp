import Foundation

public struct ImageLoaderConfiguration {
    
    public let memoryCapacity: Int
    public let diskCapacity: Int
    public let diskCacheDirectory: String
    public let requestTimeout: TimeInterval
    public let maximumConcurrentRequests: Int
    
    public static let `default` = ImageLoaderConfiguration(
        memoryCapacity: 50 * 1024 * 1024, // 50 MB
        diskCapacity: 100 * 1024 * 1024,  // 100 MB
        diskCacheDirectory: "ImageCache",
        requestTimeout: 15.0,
        maximumConcurrentRequests: 4
    )
    
}
