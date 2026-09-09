import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Absensi", systemImage: "checkmark.circle.fill")
                }
                .tag(0)
            
            AttendanceHistoryView()
                .tabItem {
                    Label("Riwayat", systemImage: "list.bullet.rectangle")
                }
                .tag(1)
            
            MonthlyReportView()
                .tabItem {
                    Label("Laporan", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.circle.fill")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
}
