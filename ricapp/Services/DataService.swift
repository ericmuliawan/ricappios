import Foundation
import SwiftUI

@MainActor
final class Store: ObservableObject {
    @Published private(set) var currentEmployeeId: String?
    
    @Published private(set) var users: [User] = []
    @Published private(set) var attendances: [Attendance] = []
    
    private let usersFile: URL
    private let attendanceFile: URL
    
    private static let employeesKey = "currentEmployeeId"
    
    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        usersFile = docs.appendingPathComponent("users.json")
        attendanceFile = docs.appendingPathComponent("attendances.json")
        
        self.users = Self.load([User].self, from: usersFile) ?? []
        self.attendances = Self.load([Attendance].self, from: attendanceFile) ?? []
        self.currentEmployeeId = UserDefaults.standard.string(forKey: Self.employeesKey)
    }
    
    // MARK: - User
    
    @discardableResult
    func createUser(name: String, employeeId: String, department: String, position: String) -> Bool {
        guard !users.contains(where: { $0.employeeId == employeeId }) else {
            return false
        }
        
        let user = User(name: name, employeeId: employeeId, department: department, position: position)
        users.append(user)
        setCurrentEmployeeId(employeeId)
        persist()
        return true
    }
    
    func getUser(byEmployeeId employeeId: String) -> User? {
        users.first { $0.employeeId == employeeId }
    }
    
    func getCurrentUser() -> User? {
        guard let employeeId = currentEmployeeId else { return nil }
        return getUser(byEmployeeId: employeeId)
    }
    
    func setCurrentEmployeeId(_ employeeId: String) {
        currentEmployeeId = employeeId
        UserDefaults.standard.set(employeeId, forKey: Self.employeesKey)
    }
    
    func logout() {
        currentEmployeeId = nil
        UserDefaults.standard.removeObject(forKey: Self.employeesKey)
    }
    
    // MARK: - Attendance
    
    func getTodayAttendance(userId: UUID) -> Attendance? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return attendances.first { attendance in
            attendance.userId == userId && attendance.date >= startOfDay && attendance.date < endOfDay
        }
    }
    
    func getAttendanceHistory(userId: UUID) -> [Attendance] {
        attendances
            .filter { $0.userId == userId }
            .sorted { $0.date > $1.date }
    }
    
    func getMonthlyAttendance(userId: UUID, month: Date) -> [Attendance] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }
        
        return attendances.filter { attendance in
            attendance.userId == userId && attendance.date >= startOfMonth && attendance.date < endOfMonth
        }
    }
    
    func createAttendance(userId: UUID) -> Attendance {
        let attendance = Attendance(userId: userId)
        attendances.append(attendance)
        persist()
        return attendance
    }
    
    func upsertAttendance(_ attendance: Attendance) {
        if let index = attendances.firstIndex(where: { $0.id == attendance.id }) {
            attendances[index] = attendance
        } else {
            attendances.append(attendance)
        }
        persist()
    }
    
    @discardableResult
    func performCheckIn(userId: UUID, photoData: Data?, latitude: Double, longitude: Double, locationName: String) -> Attendance? {
        var attendance: Attendance
        if let existing = getTodayAttendance(userId: userId) {
            attendance = existing
        } else {
            attendance = Attendance(userId: userId)
        }
        
        attendance.checkInTime = Date()
        attendance.photoData = photoData
        attendance.latitude = latitude
        attendance.longitude = longitude
        attendance.locationName = locationName
        attendance.status = .checkedIn
        upsertAttendance(attendance)
        return attendance
    }
    
    @discardableResult
    func performCheckOut(userId: UUID) -> Attendance? {
        guard var attendance = getTodayAttendance(userId: userId) else { return nil }
        attendance.checkOutTime = Date()
        attendance.status = .checkedOut
        upsertAttendance(attendance)
        return attendance
    }
    
    // MARK: - Persistence
    
    private func persist() {
        Self.save(users, to: usersFile)
        Self.save(attendances, to: attendanceFile)
    }
    
    private static func save<T: Encodable>(_ value: T, to url: URL) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(value)
            try data.write(to: url, options: .atomic)
        } catch {
            print("Error saving to \(url.lastPathComponent): \(error)")
        }
    }
    
    private static func load<T: Decodable>(_ type: T.Type, from url: URL) -> T? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error loading \(url.lastPathComponent): \(error)")
            return nil
        }
    }
}