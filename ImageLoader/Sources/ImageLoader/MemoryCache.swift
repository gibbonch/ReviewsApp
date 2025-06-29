import UIKit

public final class MemoryCache {
    
    private let cache = NSCache<NSString, UIImage>()
    
    public init(capacity: Int) {
        cache.totalCostLimit = capacity
    }
    
    public func setImage(_ image: UIImage, forKey key: String) {
        let cost = Int(image.size.width * image.size.height * 4)
        cache.setObject(image, forKey: NSString(string: key), cost: cost)
    }
    
    public func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: NSString(string: key))
    }
    
    public func removeImage(forKey key: String) {
        cache.removeObject(forKey: NSString(string: key))
    }
    
    public func clearAll() {
        cache.removeAllObjects()
    }
    
}
