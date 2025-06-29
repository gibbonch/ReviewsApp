import UIKit

struct ReviewsTotalCellConfig {
    static let reuseId = String(describing: ReviewsTotalCellConfig.self)
    
    let id = UUID()
    let totalText: NSAttributedString
    
    fileprivate let layout = ReviewsTotalCellLayout()
}

// MARK: - TableCellConfig

extension ReviewsTotalCellConfig: TableCellConfig {
    
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewsTotalCell else { return }
        cell.totalLabel.attributedText = totalText
        cell.config = self
    }
    
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Cell

final class ReviewsTotalCell: UITableViewCell {
    
    fileprivate var config: Config?
    fileprivate let totalLabel = UILabel()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTotalLabel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        totalLabel.frame = layout.totalLabelFrame
    }
    
}

// MARK: - Private

extension ReviewsTotalCell {
    func setupTotalLabel() {
        contentView.addSubview(totalLabel)
        totalLabel.textAlignment = .center
    }
}

// MARK: - Layout

private final class ReviewsTotalCellLayout {
    
    enum Constants {
        /// Отступы от краёв ячейки до её содержимого.
        static let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    }
    
    // MARK: - Фреймы
    
    private(set) var totalLabelFrame = CGRect.zero
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentWidth = maxWidth - Constants.insets.left - Constants.insets.right
        var maxY = Constants.insets.top
        let maxX = Constants.insets.left
        
        totalLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: CGSize(width: contentWidth, height: config.totalText.boundingRect(width: contentWidth).height)
        )
        maxY = totalLabelFrame.maxY
        
        return maxY + Constants.insets.bottom
    }
    
}


// MARK: - Typealias

fileprivate typealias Config = ReviewsTotalCellConfig
