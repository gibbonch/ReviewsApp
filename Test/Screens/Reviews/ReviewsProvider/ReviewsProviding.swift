import Foundation

/// Протокол, описывающий источник отзывов.
protocol ReviewsProviding {
    
    /// Загружает отзывы, начиная с указанного смещения.
    ///
    /// - Parameters:
    ///   - offset: Смещение для пагинации. Указывает, с какого отзыва начинать загрузку.
    ///   - completion: Замыкание, вызываемое по завершении запроса.
    ///     Возвращает результат в виде `GetReviewsResult`, содержащий данные или ошибку.
    func getReviews(offset: Int, completion: @escaping (GetReviewsResult) -> Void)
    
}

/// Тип, представляющий результат загрузки отзывов.
///
/// Может содержать либо `Data` (успешный результат),
/// либо `GetReviewsError` (ошибка).
typealias GetReviewsResult = Result<Data, GetReviewsError>

/// Ошибки, которые могут возникнуть при загрузке отзывов.
enum GetReviewsError: Error {
    
    /// Некорректный URL.
    case badURL
    
    /// Ошибка обработки данных.
    /// - Parameter Error: Исходная ошибка, вызвавшая сбой.
    case badData(Error)
    
}
