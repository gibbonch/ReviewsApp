import UIKit
import ImageLoader

struct ReviewPhotoCellConfig {
    static let reuseId = String(describing: ReviewPhotoCell.self)
    let imageUrl: String
    
    func updateCell(cell: UICollectionViewCell) {
        guard let cell = cell as? ReviewPhotoCell, let url = URL(string: imageUrl) else { return }
        cell.imageView.setImage(from: url)
        cell.config = self
    }
}

final class ReviewPhotoCell: UICollectionViewCell {
    
    fileprivate var config: ReviewPhotoCellConfig?
    fileprivate let imageView = UIImageView()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .lightGray.withAlphaComponent(0.3)
    }
    
}
