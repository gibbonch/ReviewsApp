import UIKit

final class ReviewsRouter: ReviewsRouting {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func routeToReviewsPhotos(selectedIndex: Int, photos: [URL]) {
        let viewModel = ReviewPhotosViewModel(selectedIndex: selectedIndex, images: photos)
        let viewController = ReviewPhotosPageViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
    
}
