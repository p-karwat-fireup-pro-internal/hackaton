import SwiftUI

extension JobStatus {
    var polishLabel: String {
        switch self {
        case .pending:     return "Zaplanowane"
        case .in_progress: return "W trakcie"
        case .done:        return "Zakończone"
        }
    }

    var icon: IconName {
        switch self {
        case .pending:     return .clock
        case .in_progress: return .refreshCw
        case .done:        return .check
        }
    }

    var foreground: Color {
        switch self {
        case .pending:     return Color.statusPending
        case .in_progress: return Color.statusProgress
        case .done:        return Color.statusDone
        }
    }

    var softBackground: Color {
        switch self {
        case .pending:     return Color.statusPendingSoft
        case .in_progress: return Color.statusProgressSoft
        case .done:        return Color.statusDoneSoft
        }
    }
}

extension JobDTO {
    var addressWithUnit: String {
        if let unit { return "\(address) \(unit)" }
        return address
    }
}
