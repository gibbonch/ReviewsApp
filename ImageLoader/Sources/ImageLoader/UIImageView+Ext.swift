import UIKit

private var imageLoadTaskKey: UInt8 = 0

public extension UIImageView {
    
    private var imageLoadTask: URLSessionDataTask? {
        get { objc_getAssociatedObject(self, &imageLoadTaskKey) as? URLSessionDataTask }
        set { objc_setAssociatedObject(self, &imageLoadTaskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Загружает изображение по URL и устанавливает его в UIImageView.
    /// Предыдущая загрузка отменяется, если она ещё не завершена.
    func setImage(from url: URL,
                  cacheType: CacheType = .memory,
                  completion: (() -> Void)? = nil) {
        
        imageLoadTask?.cancel()
        
        imageLoadTask = ImageLoader.shared.loadImage(from: url, cacheType: cacheType) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let image):
                    self.image = image
                    completion?()
                case .failure:
                    break
                }
            }
        }
    }
    
}

