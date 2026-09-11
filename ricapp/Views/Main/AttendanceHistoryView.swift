import SwiftUI

struct AttendanceHistoryView: View {
    @EnvironmentObject var store: Store
    @State private var currentUser: User?
    @State private var attendanceHistory: [Attendance] = []
    @State private var selectedFilter: AttendanceFilter = .all
    
    enum AttendanceFilter: String, CaseIterable {
        case all = "Semua"
        case today = "Hari Ini"
        case thisWeek = "Minggu Ini"
        case thisMonth = "Bulan Ini"
    }
    
    var body: some View {
        NavigationView {
            Group {
                if attendanceHistory.isEmpty {
                    emptyStateView
                } else {
                    attendanceList
                }
            }
            .navigationTitle("Riwayat Absensi")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadData()
            }
            .onChange(of: selectedFilter) { _ in
                loadData()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Belum Ada Riwayat")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Riwayat absensi Anda akan muncul di sini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var attendanceList: some View {
        VStack(spacing: 0) {
            filterPicker
            
            List {
                ForEach(attendanceHistory) { attendance in
                    NavigationLink(destination: AttendanceDetailView(attendance: attendance)) {
                        AttendanceRowView(attendance: attendance)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AttendanceFilter.allCases, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                    }) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedFilter == filter ? .semibold : .regular)
                            .foregroundStyle(selectedFilter == filter ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedFilter == filter ? Color.blue : Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding()
        }
    }
    
    private func loadData() {
        currentUser = store.getCurrentUser()
        
        guard let user = currentUser else { return }
        
        let allHistory = store.getAttendanceHistory(userId: user.id)
        
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedFilter {
        case .all:
            attendanceHistory = allHistory
        case .today:
            attendanceHistory = allHistory.filter { calendar.isDateInToday($0.date) }
        case .thisWeek:
            let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            attendanceHistory = allHistory.filter { $0.date >= startOfWeek }
        case .thisMonth:
            let components = calendar.dateComponents([.year, .month], from: now)
            let startOfMonth = calendar.date(from: components)!
            attendanceHistory = allHistory.filter { $0.date >= startOfMonth }
        }
    }
}

struct AttendanceRowView: View {
    let attendance: Attendance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(attendance.formattedDate)
                    .font(.headline)
                
                Spacer()
                
                Text(attendance.status.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            HStack(spacing: 16) {
                Label(attendance.formattedCheckInTime, systemImage: "arrow.up.circle")
                    .font(.subheadline)
                    .foregroundStyle(.green)
                
                Label(attendance.formattedCheckOutTime, systemImage: "arrow.down.circle")
                    .font(.subheadline)
                    .foregroundStyle(.red)
            }
            
            if !attendance.locationName.isEmpty {
                Label(attendance.locationName, systemImage: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var statusColor: Color {
        switch attendance.status {
        case .notCheckedIn: return .gray
        case .checkedIn: return .green
        case .checkedOut: return .blue
        case .late: return .orange
        case .earlyLeave: return .red
        }
    }
}

#Preview {
    AttendanceHistoryView()
        .environmentObject(Store())
}