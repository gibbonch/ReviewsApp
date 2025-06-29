import UIKit
import ImageLoader

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupRefreshControl()
        viewModel.getReviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.shared.clearCache(type: .memory)
    }
    
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] state in
            reviewsView?.tableView.reloadData()
            if state.isLoading {
                reviewsView?.startAnimating()
            } else {
                reviewsView?.stopAnimating()
            }
            
            if !state.isRefreshing {
                reviewsView?.refreshControl.endRefreshing()
            }
        }
    }
    
    func setupRefreshControl() {
        reviewsView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    
    @objc func handleRefresh() {
        viewModel.refresh()
    }
    
}
