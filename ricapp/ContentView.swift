import SwiftUI

struct ContentView: View {
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
    
    private var isLoggedIn: Bool {
        UserDefaults.standard.string(forKey: "currentEmployeeId") != nil
    }
}

#Preview {
    ContentView()
}
