import Foundation

struct UserDTO: Codable, Equatable {
    let id: String
    let email: String
    let displayName: String
    let specialization: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: UserDTO
}

struct RefreshResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

enum JobStatus: String, Codable, CaseIterable {
    case pending, in_progress, done
}

enum JobPriority: String, Codable {
    case normal, urgent
}

struct JobDTO: Codable, Identifiable, Equatable {
    let id: String
    let ticketId: String
    let category: String
    let address: String
    let unit: String?
    let district: String?
    let description: String
    let scheduledWindow: String
    let scheduledStart: String
    let estimatedDurationMin: Int
    var status: JobStatus
    let priority: JobPriority
    let contactName: String?
    let contactPhone: String?
    let travelTimeMin: Int?
    let isNew: Bool
}

struct PhotoDTO: Codable, Identifiable, Equatable {
    let id: String
    let jobId: String
    let description: String
    let mimeType: String
    let sizeBytes: Int
    let takenAt: Int
}
