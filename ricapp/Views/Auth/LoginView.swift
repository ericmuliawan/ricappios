import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var employeeId = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("Selamat Datang")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Masukkan ID Karyawan Anda")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "number")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        
                        TextField("ID Karyawan", text: $employeeId)
                            .textContentType(.username)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(.horizontal)
                
                Button(action: login) {
                    Text("Masuk")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .disabled(employeeId.isEmpty)
                
                NavigationLink("Belum punya akun? Daftar", destination: RegistrationView())
                    .font(.subheadline)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .fullScreenCover(isPresented: $isAuthenticated) {
                MainTabView()
            }
        }
    }
    
    private func login() {
        guard !employeeId.isEmpty else {
            errorMessage = "ID Karyawan harus diisi"
            showError = true
            return
        }
        
        let user = DataService.shared.getUser(byEmployeeId: employeeId, in: modelContext)
        
        if let user = user {
            UserDefaults.standard.set(user.employeeId, forKey: "currentEmployeeId")
            isAuthenticated = true
        } else {
            errorMessage = "ID Karyawan tidak ditemukan"
            showError = true
        }
    }
}

#Preview {
    LoginView()
        .modelContainer(for: User.self, inMemory: true)
}
