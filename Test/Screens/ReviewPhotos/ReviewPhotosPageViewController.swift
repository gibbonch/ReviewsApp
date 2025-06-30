import UIKit

final class ReviewPhotosPageViewController: UIPageViewController {
    
    private var viewModel: ReviewPhotosViewModel
    
    init(viewModel: ReviewPhotosViewModel) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupViewModel()
        
        setViewControllers(
            [viewModel.initialViewController()],
            direction: .forward,
            animated: false
        )
    }
    
}

private extension ReviewPhotosPageViewController {
    
    private func setupView() {
        view.backgroundColor = .systemBackground
    }
    
    func setupViewModel() {
        dataSource = viewModel
        delegate = viewModel
        
        viewModel.onStateChanged = { [weak self] state in
            self?.title = "\(state.currentIndex + 1) из \(state.viewControllers.count)"
        }
    }
}
