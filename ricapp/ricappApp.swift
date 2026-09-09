import SwiftUI
import SwiftData

@main
struct ricappApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [User.self, Attendance.self])
    }
}
