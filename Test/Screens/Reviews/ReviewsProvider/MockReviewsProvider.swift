import Foundation

/// Mock класс для загрузки отзывов из локального JSON.
final class MockReviewsProvider: ReviewsProviding {

    private let bundle: Bundle
    private let queue = DispatchQueue(label: "com.reviews-app.reviewsProviderQueue")

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

}

// MARK: - Internal

extension MockReviewsProvider {
    
    /// Загружает список отзывов из локального JSON-файла, имитируя сетевой запрос.
    /// Загрузка происходит в фоновом потоке. Для обновления UI перевести поток на main в  `completion`.
    ///
    /// - Parameters:
    ///   - offset: Смещение для пагинации. По умолчанию 0.
    ///   - completion: Замыкание, вызываемое по завершении загрузки. Возвращает `GetReviewsResult` с данными или ошибкой.
    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        queue.async { [weak self] in
            guard let url = self?.bundle.url(forResource: "getReviews.response", withExtension: "json") else {
                return completion(.failure(.badURL))
            }
            
            // Симулируем сетевой запрос - не менять
            usleep(.random(in: 100_000...1_000_000))

            do {
                let data = try Data(contentsOf: url)
                completion(.success(data))
            } catch {
                completion(.failure(.badData(error)))
            }
        }
    }

}
