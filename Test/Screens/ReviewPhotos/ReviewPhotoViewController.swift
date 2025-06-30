import UIKit

final class ReviewPhotoViewController: UIViewController {
    
    private lazy var reviewPhotoView = ReviewPhotoView()
    private var image: UIImage?
    private var url: URL?
    
    override func loadView() {
        view = reviewPhotoView
    }
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        self.image = image
    }
    
    init(url: URL) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImageSource()
    }
    
}

// MARK: - Private

private extension ReviewPhotoViewController {
    
    func setImageSource() {
        if let image {
            reviewPhotoView.setImage(image)
        } else if let url {
            reviewPhotoView.setImage(from: url)
        }
    }
    
}
