import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var cameraService: CameraService
    
    let onCapture: (Data?) -> Void
    
    @State private var previewLayer: AVCaptureVideoPreviewLayer?
    @State private var showPreview = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if showPreview, let image = capturedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()
                } else if let previewLayer = previewLayer {
                    CameraPreviewView(previewLayer: previewLayer)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                        .tint(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") {
                        cameraService.stopSession()
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Ambil Foto Selfie")
                        .foregroundStyle(.white)
                        .font(.headline.weight(.semibold))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if showPreview {
                        Button("Gunakan") {
                            cameraService.stopSession()
                            onCapture(capturedImage?.jpegData(compressionQuality: 0.8))
                            dismiss()
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .overlay {
                if !showPreview {
                    VStack {
                        Spacer()
                        
                        Button(action: takePhoto) {
                            Circle()
                                .stroke(.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                                .overlay {
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 65, height: 65)
                                }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            cameraService.startSession()
            previewLayer = cameraService.getPreviewLayer()
        }
        .onDisappear {
            cameraService.stopSession()
        }
    }
    
    private func takePhoto() {
        cameraService.capturePhoto { photoData in
            if let data = photoData, let image = UIImage(data: data) {
                capturedImage = image
                showPreview = true
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

#Preview {
    CameraView(cameraService: CameraService()) { _ in }
}
