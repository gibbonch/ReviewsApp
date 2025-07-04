import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProviding
    private let decoder: JSONDecoder
    private let router: ReviewsRouting

    init(
        state: State = State(),
        reviewsProvider: ReviewsProviding = MockReviewsProvider(),
        decoder: JSONDecoder = JSONDecoder(),
        router: ReviewsRouting
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.decoder = decoder
        self.router = router
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            DispatchQueue.main.async {
                self?.gotReviews(result)
            }
        }
    }
    
    func refresh() {
        state.offset = 0
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset) { [weak self] result in
            DispatchQueue.main.async {
                self?.gotReviews(result)
            }
        }
    }

}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
            
            if !state.shouldLoad {
                state.items.append(makeReviewsTotalItem(reviews.count))
            }
            state.isRefreshing = false
            state.isLoading = false
        } catch {
            state.shouldLoad = true
        }
        
        onStateChange?(state)
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    typealias ReviewsTotalItem = ReviewsTotalCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let username = (review.firstName + " " + review.lastName).attributed(font: .username)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let photoItems = review.photoUrls?.compactMap(ReviewPhotoCellConfig.init)
        
        return ReviewItem(
            avatarUrl: URL(string: review.avatarUrl ?? ""),
            username: username,
            rating: review.rating,
            reviewText: reviewText,
            created: created,
            reviewPhotoItems: photoItems ?? [],
            onTapShowMore: { [weak self] id in self?.showMoreReview(with: id) },
            onTapPhotoCell: handlePhotoCellTap
        )
    }
    
    func handlePhotoCellTap(id: UUID, index: Int) {
        let item = state.items
            .compactMap { $0 as? ReviewItem }
            .first { $0.id == id }
        
        let photos = item?.reviewPhotoItems
            .map { $0.imageUrl }
            .compactMap { URL(string: $0) }
        
        if let photos {
            router.routeToReviewsPhotos(selectedIndex: index, photos: photos)
        }
    }
    
    func makeReviewsTotalItem(_ total: Int) -> ReviewsTotalItem {
        let form: String
        let rem100 = total % 100
        let rem10 = total % 10
        
        if rem100 >= 11 && rem100 <= 14 {
            form = "отзывов"
        } else {
            switch rem10 {
            case 1:
                form = "отзыв"
            case 2, 3, 4:
                form = "отзыва"
            default:
                form = "отзывов"
            }
        }
        
        let text = "\(total) \(form)".attributed(font: .reviewCount, color: .reviewCount)
        return .init(totalText: text)
    }

}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
