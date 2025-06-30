import UIKit

final class ReviewsScreenFactory {

    /// Создаёт контроллер списка отзывов, проставляя нужные зависимости.
    func makeReviewsController(navigationController: UINavigationController) -> ReviewsViewController {
        let reviewsProvider = MockReviewsProvider()
        let router = ReviewsRouter(navigationController: navigationController)
        let viewModel = ReviewsViewModel(reviewsProvider: reviewsProvider, router: router)
        let controller = ReviewsViewController(viewModel: viewModel)
        return controller
    }

}
