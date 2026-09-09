import SwiftUI

struct AttendanceDetailView: View {
    let attendance: Attendance
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let photoData = attendance.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                infoCard
                timeCard
                locationCard
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Detail Absensi")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Informasi")
                .font(.headline)
            
            Divider()
            
            HStack {
                Text("Tanggal")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(attendance.formattedDate)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Status")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(attendance.status.rawValue)
                    .fontWeight(.medium)
                    .foregroundStyle(statusColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Waktu")
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
            
            Divider()
            
            HStack {
                Label("Durasi Kerja", systemImage: "clock")
                    .foregroundStyle(.blue)
                Spacer()
                Text(attendance.formattedWorkDuration)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var locationCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Lokasi", systemImage: "location.fill")
                .font(.headline)
            
            Divider()
            
            if attendance.locationName.isEmpty {
                Text("Tidak ada data lokasi")
                    .foregroundStyle(.secondary)
            } else {
                Text(attendance.locationName)
                
                Text("Koordinat: \(attendance.latitude), \(attendance.longitude)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
    NavigationStack {
        AttendanceDetailView(attendance: Attendance(userId: UUID()))
    }
}
