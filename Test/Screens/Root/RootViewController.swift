import UIKit

final class RootViewController: UIViewController {

    private lazy var rootView = RootView(onTapReviews: openReviews)

    override func loadView() {
        view = rootView
    }

}

// MARK: - Private

private extension RootViewController {

    func openReviews() {
        guard let navigationController else { return }
        let factory = ReviewsScreenFactory()
        let controller = factory.makeReviewsController(navigationController: navigationController)
        navigationController.pushViewController(controller, animated: true)
    }

}
