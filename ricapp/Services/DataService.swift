import Foundation
import SwiftData

class DataService {
    static let shared = DataService()
    
    private init() {}
    
    func createUser(name: String, employeeId: String, department: String, position: String, in context: ModelContext) -> User {
        let user = User(name: name, employeeId: employeeId, department: department, position: position)
        context.insert(user)
        saveContext(context)
        return user
    }
    
    func getUser(byEmployeeId employeeId: String, in context: ModelContext) -> User? {
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { user in
            user.employeeId == employeeId
        })
        return try? context.fetch(descriptor).first
    }
    
    func getCurrentUser(in context: ModelContext) -> User? {
        guard let employeeId = UserDefaults.standard.string(forKey: "currentEmployeeId") else {
            return nil
        }
        return getUser(byEmployeeId: employeeId, in: context)
    }
    
    func createAttendance(userId: UUID, in context: ModelContext) -> Attendance {
        let attendance = Attendance(userId: userId)
        context.insert(attendance)
        saveContext(context)
        return attendance
    }
    
    func getTodayAttendance(userId: UUID, in context: ModelContext) -> Attendance? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Attendance>(predicate: #Predicate { attendance in
            attendance.userId == userId && attendance.date >= startOfDay && attendance.date < endOfDay
        })
        return try? context.fetch(descriptor).first
    }
    
    func getAttendanceHistory(userId: UUID, in context: ModelContext) -> [Attendance] {
        let descriptor = FetchDescriptor<Attendance>(
            predicate: #Predicate { attendance in
                attendance.userId == userId
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func getMonthlyAttendance(userId: UUID, month: Date, in context: ModelContext) -> [Attendance] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }
        
        let descriptor = FetchDescriptor<Attendance>(predicate: #Predicate { attendance in
            attendance.userId == userId && attendance.date >= startOfMonth && attendance.date < endOfMonth
        })
        return (try? context.fetch(descriptor)) ?? []
    }
    
    private func saveContext(_ context: ModelContext) {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
