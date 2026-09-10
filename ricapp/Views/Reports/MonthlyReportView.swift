import SwiftUI

struct MonthlyReportView: View {
    @EnvironmentObject var store: Store
    @State private var currentUser: User?
    @State private var selectedMonth = Date()
    @State private var monthlyAttendance: [Attendance] = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            Group {
                if monthlyAttendance.isEmpty {
                    emptyStateView
                } else {
                    reportContent
                }
            }
            .navigationTitle("Laporan Bulanan")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadData()
            }
            .onChange(of: selectedMonth) { _ in
                loadData()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Belum Ada Data")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Tidak ada data absensi pada bulan ini")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var reportContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                monthPicker
                summaryCards
                monthlyList
            }
            .padding()
        }
    }
    
    private var monthPicker: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title3)
            }
            
            Spacer()
            
            Text(monthYearLabel)
                .font(.headline)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: selectedMonth).uppercased()
    }
    
    private var summaryCards: some View {
        VStack(spacing: 12) {
            let workingDays = workingDaysCount
            let presentDays = presentDaysCount
            let totalHours = totalWorkHours
            let absentDays = max(0, workingDays - presentDays)
            let avgHours = averageHoursPerDay
            
            HStack(spacing: 12) {
                SummaryCard(
                    icon: "calendar",
                    title: "Hari Masuk",
                    value: "\(presentDays)",
                    color: .green
                )
                
                SummaryCard(
                    icon: "clock",
                    title: "Total Jam",
                    value: totalHours,
                    color: .blue
                )
            }
            
            HStack(spacing: 12) {
                SummaryCard(
                    icon: "calendar.badge.exclamationmark",
                    title: "Tidak Hadir",
                    value: "\(absentDays)",
                    color: .red
                )
                
                SummaryCard(
                    icon: "clock.arrow.circlepath",
                    title: "Rata-rata",
                    value: avgHours,
                    color: .orange
                )
            }
        }
    }
    
    private var monthlyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Detail Harian")
                .font(.headline)
            
            ForEach(monthlyAttendance) { attendance in
                HStack {
                    VStack(alignment: .leading) {
                        Text(dayLabel(attendance.date))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(attendance.locationName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(attendance.formattedCheckInTime) - \(attendance.formattedCheckOutTime)")
                            .font(.subheadline)
                        
                        Text(attendance.formattedWorkDuration)
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    private var workingDaysCount: Int {
        return monthlyAttendance.count
    }
    
    private var presentDaysCount: Int {
        return monthlyAttendance.filter { $0.checkInTime != nil }.count
    }
    
    private var totalWorkHours: String {
        let durations = monthlyAttendance.compactMap { $0.workDuration }
        let totalSeconds = durations.reduce(0) { $0 + $1 }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        return "\(hours)j \(minutes)m"
    }
    
    private var averageHoursPerDay: String {
        let durations = monthlyAttendance.compactMap { $0.workDuration }
        guard !durations.isEmpty else { return "-" }
        
        let totalSeconds = durations.reduce(0) { $0 + $1 }
        let averageSeconds = totalSeconds / Double(durations.count)
        let hours = Int(averageSeconds) / 3600
        let minutes = (Int(averageSeconds) % 3600) / 60
        return "\(hours)j \(minutes)m"
    }
    
    private func dayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    private func loadData() {
        currentUser = store.getCurrentUser()
        
        guard let user = currentUser else { return }
        
        monthlyAttendance = store.getMonthlyAttendance(userId: user.id, month: selectedMonth)
    }
}

struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MonthlyReportView()
        .environmentObject(Store())
}