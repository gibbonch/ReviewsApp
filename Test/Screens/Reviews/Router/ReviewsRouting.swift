import UIKit

/// Протокол, описывающий навигацию на экране `Reviews`.
protocol ReviewsRouting {
    
    var navigationController: UINavigationController { get }
    func routeToReviewsPhotos(selectedIndex: Int, photos: [URL])
    
}
