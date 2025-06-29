import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        activityIndicator.center = center
    }

}

// MARK: - Internal

extension ReviewsView {
    
    func startAnimating() {
        activityIndicator.startAnimating()
        tableView.isHidden = true
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        tableView.isHidden = false
    }
    
}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicator()
    }
    
    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewsTotalCell.self, forCellReuseIdentifier: ReviewsTotalCellConfig.reuseId)
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
}
