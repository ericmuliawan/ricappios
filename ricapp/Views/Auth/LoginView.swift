import SwiftUI

struct LoginView: View {
    @EnvironmentObject var store: Store
    
    @State private var employeeId = ""
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
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
                
                Button(action: callback) {
                    Text("show callback")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .disabled(employeeId.isEmpty)
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
    
    private func login() {
        print("run login")
        guard !employeeId.isEmpty else {
            errorMessage = "ID Karyawan harus diisi"
            showError = true
            return
        }
        
        if store.getUser(byEmployeeId: employeeId) != nil {
            store.setCurrentEmployeeId(employeeId)
        } else {
            errorMessage = "ID Karyawan tidak ditemukan"
            showError = true
        }
    }
    
    private func callback() {
        print("run")
        presentAlert()
    }
}

#Preview {
    LoginView()
        .environmentObject(Store())
}
