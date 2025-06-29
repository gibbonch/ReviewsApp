import UIKit
import ImageLoader

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Ссылка на аватар пользователя.
    let avatarUrl: URL?
    /// Имя и фамилия пользователя.
    let username: NSAttributedString
    /// Рейтинг.
    let rating: Int
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Ссылки на изображения в отзыве.
    let reviewPhotoItems: [ReviewPhotoCellConfig]
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
    /// Объект создает изображение рейтинга.
    private let ratingRenderer = RatingRenderer()
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        cell.avatarImageView.image = .avatarPlaceholder
        if let avatarUrl {
            cell.avatarImageView.setImage(from: avatarUrl)
        }
        cell.usernameLabel.attributedText = username
        cell.ratingImageView.image = ratingRenderer.ratingImage(rating)
        cell.photosCollectionView.reloadData()
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Private

private extension ReviewCellConfig {
    
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    fileprivate var config: Config?
    
    fileprivate let avatarImageView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate let photosCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        usernameLabel.frame = layout.usernameLabelFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        photosCollectionView.frame = layout.photosCollectionViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
}

// MARK: - Private

private extension ReviewCell {
    
    func setupCell() {
        setupAvatarImageView()
        setupUsernameLabel()
        setupRatingImageView()
        setupCollectionView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = Layout.Constants.avatarCornerRadius
        avatarImageView.layer.masksToBounds = true
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
    }
    
    func setupCollectionView() {
        contentView.addSubview(photosCollectionView)
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.register(
            ReviewPhotoCell.self,
            forCellWithReuseIdentifier: ReviewPhotoCellConfig.reuseId
        )
        photosCollectionView.backgroundColor = .clear
        photosCollectionView.isScrollEnabled = false
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    
    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addAction(UIAction(handler: { [weak self] _ in
            guard let self, let config else { return }
            config.onTapShowMore(config.id)
        }), for: .touchUpInside)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ReviewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        config?.reviewPhotoItems.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReviewPhotoCellConfig.reuseId,
            for: indexPath
        )
        
        let config = self.config?.reviewPhotoItems[indexPath.row]
        config?.updateCell(cell: cell)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension ReviewCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        Layout.Constants.photoSize
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        Layout.Constants.photosSpacing
    }
    
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    enum Constants {
        static let avatarSize = CGSize(width: 36.0, height: 36.0)
        static let ratingSize = CGSize(width: 85, height: 16)
        static let photoSize = CGSize(width: 55.0, height: 66.0)
        static let showMoreButtonSize = Config.showMoreText.size()
        
        static let photoCornerRadius = 8.0
        static let avatarCornerRadius = 18.0
        static let photosSpacing = 8.0
        
        /// Отступы от краёв ячейки до её содержимого.
        static let contentInsets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
        /// Горизонтальный отступ от аватара до имени пользователя.
        static let avatarToUsernameSpacing = 10.0
        /// Вертикальный отступ от имени пользователя до вью рейтинга.
        static let usernameToRatingSpacing = 6.0
        /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
        static let ratingToTextSpacing = 6.0
        /// Вертикальный отступ от вью рейтинга до фото.
        static let ratingToPhotosSpacing = 10.0
        /// Вертикальный отступ от фото (если они есть) до текста отзыва.
        static let photosToTextSpacing = 10.0
        /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
        static let reviewTextToCreatedSpacing = 6.0
        /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
        static let showMoreToCreatedSpacing = 6.0
    }
    
    // MARK: - Фреймы
    
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var photosCollectionViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentWidth = maxWidth - Constants.contentInsets.left - Constants.contentInsets.right
        var maxY = Constants.contentInsets.top
        var maxX = Constants.contentInsets.left
        var showShowMoreButton = false
        
        // Avatar
        avatarImageViewFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: Constants.avatarSize
        )
        maxX = avatarImageViewFrame.maxX + Constants.avatarToUsernameSpacing
        
        // Username
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.username.boundingRect(width: contentWidth - maxX).size
        )
        maxY = usernameLabelFrame.maxY + Constants.usernameToRatingSpacing
        
        // Rating
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: Constants.ratingSize
        )
        
        // Photos
        if !config.reviewPhotoItems.isEmpty {
            maxY = ratingImageViewFrame.maxY + Constants.ratingToPhotosSpacing
            let count = CGFloat(config.reviewPhotoItems.count)
            let spacingWidth = (count - 1) * Constants.photosSpacing
            let photosWidth = Constants.photoSize.width * count
            photosCollectionViewFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: CGSize(width: photosWidth + spacingWidth, height: Constants.photoSize.height)
            )
            maxY = photosCollectionViewFrame.maxY + Constants.photosToTextSpacing
        } else {
            photosCollectionViewFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: .zero
            )
            maxY = ratingImageViewFrame.maxY + Constants.ratingToTextSpacing
        }
        
        // Review text
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: contentWidth - maxX).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: config.reviewText.boundingRect(width: contentWidth - maxX, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + Constants.reviewTextToCreatedSpacing
        }
        
        // Show more button
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: Constants.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + Constants.showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        // Created
        createdLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.created.boundingRect(width: contentWidth - maxX).size
        )
        
        return createdLabelFrame.maxY + Constants.contentInsets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
