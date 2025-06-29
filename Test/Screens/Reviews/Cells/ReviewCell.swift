import UIKit
import ImageLoader

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Ссылка на аватар пользователя.
    let avatarUrl: String?
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
        if let avatarUrl, let url = URL(string: avatarUrl) {
            cell.avatarImageView.setImage(from: url)
        }
        cell.usernameLabel.attributedText = username
        cell.ratingImageView.image = ratingRenderer.ratingImage(rating)
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
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
    }
    
    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
        avatarImageView.layer.masksToBounds = true
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
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

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    fileprivate static let ratingSize = CGSize(width: 85, height: 16)
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentWidth = maxWidth - insets.left - insets.right
        var maxY = insets.top
        
        avatarImageViewFrame = calculateAvatarFrame(originY: maxY)
        
        usernameLabelFrame = calculateUsernameFrame(
            config: config,
            originX: avatarImageViewFrame.maxX + avatarToUsernameSpacing,
            originY: maxY,
            maxWidth: contentWidth - avatarImageViewFrame.maxX - avatarToUsernameSpacing
        )
        maxY = usernameLabelFrame.maxY + usernameToRatingSpacing
        
        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: usernameLabelFrame.minX, y: maxY),
            size: Self.ratingSize
        )
        maxY = ratingImageViewFrame.maxY + ratingToTextSpacing
        
        var showShowMoreButton = false
        
        if !config.reviewText.isEmpty() {
            let textOrigin = CGPoint(x: usernameLabelFrame.minX, y: maxY)
            let (textFrame, shouldShowMore) = calculateReviewTextFrame(config: config, origin: textOrigin, maxWidth: contentWidth - avatarImageViewFrame.maxX - avatarToUsernameSpacing)
            reviewTextLabelFrame = textFrame
            maxY = textFrame.maxY + reviewTextToCreatedSpacing
            showShowMoreButton = shouldShowMore
        }
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(origin: CGPoint(x: usernameLabelFrame.minX, y: maxY), size: Self.showMoreButtonSize)
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        createdLabelFrame = CGRect(
            origin: CGPoint(x: usernameLabelFrame.minX, y: maxY),
            size: config.created.boundingRect(width: contentWidth - avatarImageViewFrame.maxX - avatarToUsernameSpacing).size
        )
        
        return createdLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Private

private extension ReviewCellLayout {
    func calculateAvatarFrame(originY: CGFloat) -> CGRect {
        CGRect(
            origin: CGPoint(x: insets.left, y: originY),
            size: Self.avatarSize
        )
    }
    
    func calculateUsernameFrame(config: Config, originX: CGFloat, originY: CGFloat, maxWidth: CGFloat) -> CGRect {
        let size = config.username.boundingRect(width: maxWidth).size
        return CGRect(origin: CGPoint(x: originX, y: originY), size: size)
    }
    
    func calculateReviewTextFrame(config: Config, origin: CGPoint, maxWidth: CGFloat) -> (CGRect, Bool) {
        let lineHeight = config.reviewText.font()?.lineHeight ?? .zero
        let maxHeight = lineHeight * CGFloat(config.maxLines)
        let fullHeight = config.reviewText.boundingRect(width: maxWidth).height
        
        let shouldShowMore = config.maxLines != .zero && fullHeight > maxHeight
        let height = config.maxLines == 0 ? fullHeight : min(fullHeight, maxHeight)
        let size = config.reviewText.boundingRect(width: maxWidth, height: height).size
        let frame = CGRect(origin: origin, size: size)
        
        return (frame, shouldShowMore)
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
