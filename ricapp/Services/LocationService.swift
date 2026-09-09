import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var locationName: String = ""
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        reverseGeocode(location: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        case .denied, .restricted:
            print("Location access denied")
        default:
            break
        }
    }
    
    private func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first else { return }
            
            var name = ""
            if let thoroughfare = placemark.thoroughfare {
                name += thoroughfare
            }
            if let subThoroughfare = placemark.subThoroughfare {
                name = "\(subThoroughfare) " + name
            }
            if let locality = placemark.locality {
                name += ", \(locality)"
            }
            
            DispatchQueue.main.async {
                self?.locationName = name
            }
        }
    }
    
    func getCurrentLocation(completion: @escaping (CLLocation?, String) -> Void) {
        guard let location = self.location else {
            completion(nil, "Lokasi tidak tersedia")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            var name = ""
            if let placemark = placemarks?.first {
                if let thoroughfare = placemark.thoroughfare {
                    name += thoroughfare
                }
                if let locality = placemark.locality {
                    name += ", \(locality)"
                }
            }
            completion(location, name)
        }
    }
}
