import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentUser: User?
    @State private var showLogoutConfirm = false
    @State private var showMainView = false
    
    var body: some View {
        NavigationStack {
            Group {
                if let user = currentUser {
                    profileContent(user: user)
                } else {
                    Text("Data tidak ditemukan")
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadData()
            }
            .alert("Keluar dari Akun?", isPresented: $showLogoutConfirm) {
                Button("Batal", role: .cancel) {}
                Button("Keluar", role: .destructive) {
                    logout()
                }
            } message: {
                Text("Anda yakin ingin keluar dari app?")
            }
            .fullScreenCover(isPresented: $showMainView) {
                ContentView()
            }
        }
    }
    
    private func profileContent(user: User) -> some View {
        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user.name)
                            .font(.headline)
                        
                        Text("ID: \(user.employeeId)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Informasi Pribadi")) {
                infoRow(icon: "building.2.fill", title: "Departemen", value: user.department.isEmpty ? "-" : user.department)
                infoRow(icon: "briefcase.fill", title: "Jabatan", value: user.position.isEmpty ? "-" : user.position)
            }
            
            Section(header: Text("Informasi Akun")) {
                infoRow(icon: "person.fill", title: "Nama", value: user.name)
                infoRow(icon: "number", title: "ID Karyawan", value: user.employeeId)
                
                HStack {
                    Label("Terdaftar Sejak", systemImage: "calendar")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(registerDateLabel(user.createdAt))
                        .foregroundStyle(.primary)
                }
            }
            
            Section {
                Button(action: {
                    showLogoutConfirm = true
                }) {
                    Label("Keluar dari Akun", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func infoRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
    }
    
    private func registerDateLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: date)
    }
    
    private func loadData() {
        currentUser = DataService.shared.getCurrentUser(in: modelContext)
    }
    
    private func logout() {
        UserDefaults.standard.removeObject(forKey: "currentEmployeeId")
        showMainView = true
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: User.self, inMemory: true)
}
