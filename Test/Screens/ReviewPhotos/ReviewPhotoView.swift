import UIKit
import ImageLoader

final class ReviewPhotoView: UIView {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        
        if imageView.image != nil {
            updateImageViewFrame()
            centerImage()
        }
    }
    
    func setImage(_ image: UIImage) {
        imageView.image = image
        updateImageViewFrame()
        centerImage()
    }
    
    func setImage(from url: URL) {
        imageView.setImage(from: url) { [weak self] in
            self?.updateImageViewFrame()
            self?.centerImage()
        }
    }
    
}

// MARK: - Private

private extension ReviewPhotoView {
    
    func setupView() {
        setupScrollView()
        setupImageView()
    }
    
    func setupScrollView() {
        addSubview(scrollView)
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.zoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func setupImageView() {
        scrollView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
    }
    
    func updateImageViewFrame() {
        guard let image = imageView.image else { return }
        
        let scrollViewSize = scrollView.bounds.size
        
        guard scrollViewSize.width > 0 && scrollViewSize.height > 0 else { return }
        
        let imageSize = image.size
        
        let scaleX = scrollViewSize.width / imageSize.width
        let scaleY = scrollViewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        
        let imageViewSize = CGSize(
            width: imageSize.width * scale,
            height: imageSize.height * scale
        )
        
        imageView.frame = CGRect(origin: .zero, size: imageViewSize)
        scrollView.contentSize = imageViewSize
    }
    
    func centerImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        guard scrollViewSize.width > 0 && scrollViewSize.height > 0 else { return }
        
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)
        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalPadding,
            left: horizontalPadding,
            bottom: verticalPadding,
            right: horizontalPadding
        )
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
    @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        if scrollView.zoomScale > scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            let tapLocation = gesture.location(in: imageView)
            let zoomRect = zoomRectForScale(scrollView.maximumZoomScale / 2, center: tapLocation)
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
    
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        let size = CGSize(
            width: scrollView.bounds.size.width / scale,
            height: scrollView.bounds.size.height / scale
        )
        
        return CGRect(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
    
}

// MARK: - UIScrollViewDelegate

extension ReviewPhotoView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
