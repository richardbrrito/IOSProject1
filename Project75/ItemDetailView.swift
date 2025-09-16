import SwiftUI
import PhotosUI
import Photos
import MapKit
import CoreLocation

struct ItemDetailView: View {
    @Binding var item: HuntItem
    
    // State for PHPicker
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var showPicker = false
    @State private var showSettingsAlert = false
    @State private var photoLocation: CLLocation?
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Checklist indicator
            HStack {
                Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isComplete ? .green : .red)
                Text(item.title)
                    .font(.headline)
            }
            
            // Description
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Show map with photo location if available
            if let location = photoLocation {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photo Location")
                        .font(.headline)
                    
                    Map {
                        Marker("Photo Location", coordinate: location.coordinate)
                            .tint(.red)
                    }
                    .mapStyle(.standard)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .onAppear {
                        // Set the camera position to focus on the photo location
                    }
                    
                    // Show coordinates
                    Text("Lat: \(location.coordinate.latitude, specifier: "%.4f"), Lng: \(location.coordinate.longitude, specifier: "%.4f")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Custom button instead of PhotosPicker directly
            Button {
                checkPhotoLibraryPermission()
            } label: {
                Text("Attach Photo")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        
        // Present PhotosPicker if allowed
        .photosPicker(isPresented: $showPicker,
                      selection: $selectedItem,
                      matching: .images,
                      photoLibrary: .shared())
        .onChange(of: selectedItem) { oldItem, newItem in
            guard let newItem else { return }
            Task {
                await loadPhotoWithLocation(from: newItem)
            }
        }

        // Alert if user denied permission
        .alert("Photo Access Needed",
               isPresented: $showSettingsAlert) {
            Button("Open Settings") {
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please allow photo access in Settings to attach a photo.")
        }
    }
    
    // MARK: - Load photo with location data
    private func loadPhotoWithLocation(from item: PhotosPickerItem) async {
        // Load the image data
        if let data = try? await item.loadTransferable(type: Data.self),
           let uiImage = UIImage(data: data) {
            self.item.image = uiImage
        }
        
        // Load location data from the photo
        if let assetIdentifier = item.itemIdentifier {
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            if let asset = fetchResult.firstObject, let location = asset.location {
                await MainActor.run {
                    self.photoLocation = location
                    self.item.imageLocation = location
                }
            }
        }
    }
    
    // MARK: - Permission handling
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            showPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.showPicker = true
                    } else {
                        self.showSettingsAlert = true
                    }
                }
            }
        default:
            showSettingsAlert = true
        }
    }
}
