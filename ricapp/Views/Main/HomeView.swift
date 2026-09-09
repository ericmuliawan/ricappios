import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationService = LocationService()
    @StateObject private var cameraService = CameraService()
    
    @State private var currentUser: User?
    @State private var todayAttendance: Attendance?
    @State private var isCheckedIn = false
    @State private var showCamera = false
    @State private var showLocationAlert = false
    @State private var currentTime = Date()
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    timeSection
                    
                    statusCard
                    
                    checkInOutButton
                    
                    if let attendance = todayAttendance {
                        attendanceInfoCard(attendance: attendance)
                    }
                    
                    locationSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Absensi")
            .navigationBarTitleDisplayMode(.large)
            .onReceive(timer) { _ in
                currentTime = Date()
            }
            .onAppear {
                loadData()
                locationService.requestPermission()
            }
            .sheet(isPresented: $showCamera) {
                CameraView(cameraService: cameraService) { photoData in
                    handleCheckIn(photoData: photoData)
                }
            }
            .alert("Lokasi Tidak Tersedia", isPresented: $showLocationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Aktifkan layanan lokasi di Pengaturan untuk menggunakan fitur ini")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let user = currentUser {
                Text("Halo, \(user.name)!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("ID: \(user.employeeId)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var timeSection: some View {
        VStack(spacing: 8) {
            Text(currentTime, format: .dateTime.hour().minute().second())
                .font(.system(size: 48, weight: .bold, design: .monospaced))
            
            Text(currentTime, format: .dateTime.weekday(.wide).day().month(.wide).year())
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Status Hari Ini")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(statusText)
                    .font(.headline)
                    .foregroundStyle(statusColor)
            }
            
            Spacer()
            
            Image(systemName: statusIcon)
                .font(.title)
                .foregroundStyle(statusColor)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var checkInOutButton: some View {
        Button(action: {
            if isCheckedIn {
                handleCheckOut()
            } else {
                showCamera = true
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: isCheckedIn ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                    .font(.system(size: 60))
                
                Text(isCheckedIn ? "Check Out" : "Check In")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
            .background(
                LinearGradient(
                    colors: isCheckedIn ? [.red, .orange] : [.green, .blue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: isCheckedIn ? .red.opacity(0.3) : .green.opacity(0.3), radius: 15, x: 0, y: 10)
        }
    }
    
    private func attendanceInfoCard(attendance: Attendance) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi Absensi")
                .font(.headline)
            
            Divider()
            
            HStack {
                Label("Check In", systemImage: "arrow.up.circle")
                    .foregroundStyle(.green)
                
                Spacer()
                
                Text(attendance.formattedCheckInTime)
                    .fontWeight(.medium)
            }
            
            HStack {
                Label("Check Out", systemImage: "arrow.down.circle")
                    .foregroundStyle(.red)
                
                Spacer()
                
                Text(attendance.formattedCheckOutTime)
                    .fontWeight(.medium)
            }
            
            HStack {
                Label("Durasi Kerja", systemImage: "clock")
                    .foregroundStyle(.blue)
                
                Spacer()
                
                Text(attendance.formattedWorkDuration)
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Lokasi Terkini", systemImage: "location.fill")
                .font(.headline)
            
            if locationService.locationName.isEmpty {
                Text("Mendapatkan lokasi...")
                    .foregroundStyle(.secondary)
            } else {
                Text(locationService.locationName)
                    .font(.subheadline)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var statusText: String {
        if let attendance = todayAttendance {
            if attendance.checkOutTime != nil {
                return "Selesai Hari Ini"
            } else if attendance.checkInTime != nil {
                return "Sudah Check In"
            }
        }
        return "Belum Absen"
    }
    
    private var statusColor: Color {
        if let attendance = todayAttendance {
            if attendance.checkOutTime != nil {
                return .blue
            } else if attendance.checkInTime != nil {
                return .green
            }
        }
        return .gray
    }
    
    private var statusIcon: String {
        if let attendance = todayAttendance {
            if attendance.checkOutTime != nil {
                return "checkmark.circle.fill"
            } else if attendance.checkInTime != nil {
                return "clock.fill"
            }
        }
        return "circle"
    }
    
    private func loadData() {
        currentUser = DataService.shared.getCurrentUser(in: modelContext)
        
        if let user = currentUser {
            todayAttendance = DataService.shared.getTodayAttendance(userId: user.id, in: modelContext)
            
            if let attendance = todayAttendance {
                isCheckedIn = attendance.checkInTime != nil && attendance.checkOutTime == nil
            }
        }
    }
    
    private func handleCheckIn(photoData: Data?) {
        guard let user = currentUser else { return }
        
        if locationService.location == nil {
            showLocationAlert = true
            return
        }
        
        var attendance: Attendance
        if let existing = todayAttendance {
            attendance = existing
        } else {
            attendance = DataService.shared.createAttendance(userId: user.id, in: modelContext)
        }
        
        attendance.checkInTime = Date()
        attendance.photoData = photoData
        attendance.latitude = locationService.location?.coordinate.latitude ?? 0
        attendance.longitude = locationService.location?.coordinate.longitude ?? 0
        attendance.locationName = locationService.locationName
        attendance.status = .checkedIn
        
        try? modelContext.save()
        
        todayAttendance = attendance
        isCheckedIn = true
    }
    
    private func handleCheckOut() {
        guard let attendance = todayAttendance else { return }
        
        attendance.checkOutTime = Date()
        attendance.status = .checkedOut
        
        try? modelContext.save()
        
        isCheckedIn = false
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [User.self, Attendance.self], inMemory: true)
}
