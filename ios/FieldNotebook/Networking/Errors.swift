import Foundation

enum APIError: Error, Equatable {
    case unauthorized
    case forbidden
    case notFound
    case conflict(currentStatus: String?)
    case rateLimited(retryAfterSec: Int?)
    case accountLocked(lockedUntil: Date)
    case invalidRequest
    case server
    case network
    case decoding

    var userMessagePolish: String {
        switch self {
        case .unauthorized:           return "Sesja wygasła. Zaloguj się ponownie."
        case .forbidden:              return "Brak uprawnień do tej akcji."
        case .notFound:               return "Nie znaleziono."
        case .conflict:               return "Akcja niemożliwa w obecnym stanie zlecenia."
        case .rateLimited:            return "Spróbuj za chwilę."
        case .accountLocked:          return "Konto zablokowane na 15 minut."
        case .invalidRequest:         return "Nieprawidłowe dane."
        case .server, .network:       return "Brak połączenia z serwerem."
        case .decoding:               return "Błąd przetwarzania odpowiedzi."
        }
    }
}
