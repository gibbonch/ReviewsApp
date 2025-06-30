import UIKit

final class ReviewPhotosViewModel: NSObject {
    
    var onStateChanged: ((ReviewPhotosViewModelState) -> Void)? {
        didSet { onStateChanged?(state) }
    }
    
    private var state = ReviewPhotosViewModelState() {
        didSet { onStateChanged?(state) }
    }
    
    init(selectedIndex: Int, images: [URL]) {
        super.init()
        state.viewControllers = images.map(createViewController)
        state.currentIndex = selectedIndex
    }
    
    func initialViewController() -> UIViewController {
        state.viewControllers[state.currentIndex]
    }
}

// MARK: - Private

private extension ReviewPhotosViewModel {
    
    func createViewController(url: URL) -> UIViewController {
        ReviewPhotoViewController(url: url)
    }
    
    func setCurrentIndex(_ index: Int) {
        guard index >= 0 && index < state.viewControllers.count else { return }
        state.currentIndex = index
    }
    
}

// MARK: - UIPageViewControllerDataSource

extension ReviewPhotosViewModel: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = state.viewControllers.firstIndex(where: { viewController === $0 }),
              currentIndex > 0 else { return nil }
        
        return state.viewControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = state.viewControllers.firstIndex(where: { viewController === $0 }),
              currentIndex < state.viewControllers.count - 1 else { return nil }
        
        return state.viewControllers[currentIndex + 1]
    }
}

// MARK: - UIPageViewControllerDelegate

extension ReviewPhotosViewModel: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = state.viewControllers.firstIndex(of: currentViewController) else { return }
        
        setCurrentIndex(currentIndex)
    }
}
