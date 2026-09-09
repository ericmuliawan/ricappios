import Foundation
import SwiftData
import CoreLocation

@Model
final class Attendance {
    var id: UUID
    var userId: UUID
    var checkInTime: Date?
    var checkOutTime: Date?
    var date: Date
    var latitude: Double
    var longitude: Double
    var locationName: String
    var photoData: Data?
    var status: AttendanceStatus
    var notes: String
    
    init(userId: UUID) {
        self.id = UUID()
        self.userId = userId
        self.date = Date()
        self.latitude = 0
        self.longitude = 0
        self.locationName = ""
        self.status = .notCheckedIn
        self.notes = ""
    }
    
    var workDuration: TimeInterval? {
        guard let checkIn = checkInTime, let checkOut = checkOutTime else {
            return nil
        }
        return checkOut.timeIntervalSince(checkIn)
    }
    
    var formattedWorkDuration: String {
        guard let duration = workDuration else {
            return "-"
        }
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)j \(minutes)m"
    }
    
    var formattedCheckInTime: String {
        guard let time = checkInTime else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var formattedCheckOutTime: String {
        guard let time = checkOutTime else { return "-" }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
}

enum AttendanceStatus: String, Codable, CaseIterable {
    case notCheckedIn = "Belum Absen"
    case checkedIn = "Sudah Absen Masuk"
    case checkedOut = "Selesai"
    case late = "Terlambat"
    case earlyLeave = "Pulang Awal"
    
    var color: String {
        switch self {
        case .notCheckedIn: return "gray"
        case .checkedIn: return "green"
        case .checkedOut: return "blue"
        case .late: return "orange"
        case .earlyLeave: return "red"
        }
    }
}
