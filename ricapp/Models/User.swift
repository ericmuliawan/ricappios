import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: UUID
    var name: String
    var employeeId: String
    var department: String
    var position: String
    var createdAt: Date
    
    init(name: String, employeeId: String, department: String = "", position: String = "") {
        self.id = UUID()
        self.name = name
        self.employeeId = employeeId
        self.department = department
        self.position = position
        self.createdAt = Date()
    }
}