import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var employeeId = ""
    @State private var department = ""
    @State private var position = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)
                        
                        Text("Daftar Akun Baru")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Lengkapi data Anda untuk mulai menggunakan app absensi")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        CustomTextField(icon: "person.fill", title: "Nama Lengkap", placeholder: "Masukkan nama lengkap", text: $name)
                        
                        CustomTextField(icon: "number", title: "ID Karyawan", placeholder: "Masukkan ID karyawan", text: $employeeId)
                        
                        CustomTextField(icon: "building.2.fill", title: "Departemen", placeholder: "Masukkan departemen", text: $department)
                        
                        CustomTextField(icon: "briefcase.fill", title: "Jabatan", placeholder: "Masukkan jabatan", text: $position)
                    }
                    .padding(.horizontal)
                    
                    Button(action: register) {
                        Text("Daftar")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .disabled(name.isEmpty || employeeId.isEmpty)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func register() {
        guard !name.isEmpty, !employeeId.isEmpty else {
            errorMessage = "Nama dan ID Karyawan harus diisi"
            showError = true
            return
        }
        
        if store.getUser(byEmployeeId: employeeId) != nil {
            errorMessage = "ID Karyawan sudah terdaftar"
            showError = true
            return
        }
        
        store.createUser(
            name: name,
            employeeId: employeeId,
            department: department,
            position: position
        )
        
        dismiss()
    }
}

struct CustomTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    RegistrationView()
        .environmentObject(Store())
}
