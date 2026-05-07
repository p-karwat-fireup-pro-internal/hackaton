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
    case underlying(String)

    var userMessagePolish: String {
        switch self {
        case .unauthorized:    return "Sesja wygasła. Zaloguj się ponownie."
        case .forbidden:       return "Brak uprawnień do tej akcji."
        case .notFound:        return "Nie znaleziono."
        case .conflict:        return "Akcja niemożliwa w obecnym stanie zlecenia."
        case .rateLimited:     return "Spróbuj za chwilę."
        case .accountLocked:   return "Konto zablokowane na 15 minut."
        case .invalidRequest:  return "Nieprawidłowe dane."
        case .server:          return "Serwer chwilowo nie odpowiada. Spróbuj ponownie."
        case .network:         return "Brak połączenia z siecią. Zmiany zapiszą się gdy wróci sieć."
        case .decoding:        return "Nieoczekiwana odpowiedź serwera. Spróbuj ponownie."
        case .underlying:
            // Don't leak NSError descriptions or status codes to the user.
            return "Coś poszło nie tak. Spróbuj ponownie."
        }
    }
}
