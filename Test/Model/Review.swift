/// Модель отзыва.
struct Review: Decodable {

    /// Ссылка на аватар пользователя.
    let avatarUrl: String?
    /// Имя пользователя.
    let firstName: String
    /// Фамилия пользователя.
    let lastName: String
    /// Рейтинг.
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// Ссылки на изображения в отзыве.
    let photoUrls: [String]?

}
