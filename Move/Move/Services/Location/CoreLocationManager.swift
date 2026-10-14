//
//  Locationmanager.swift
//  Move
//
//  Created by David Řihák on 11.06.2026.
//

import CoreLocation

class CoreLocationManager: NSObject, LocationManaging, CLLocationManagerDelegate {
   
    private var locationManager: CLLocationManager!
    private var currentLocation: CLLocationCoordinate2D? = nil
    private var intervalTimer: Timer?
    private let updateIntervalMiniutes: Double = 5
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let isAuthorized = isLocationAuthorized()
        if isAuthorized {
            manager.startUpdatingLocation()
        }
        NotificationCenter.default.post(name: .locationAuthorizationDidChange, object: isAuthorized)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location.coordinate
            NotificationCenter.default.post(name: .locationDidUpdate, object: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error.localizedDescription)")
    }
    
    func isLocationAuthorized() -> Bool {
        let status = locationManager.authorizationStatus
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D? {
        return currentLocation
    }
    
    func getLocationDistrict(_ coordinates: CLLocationCoordinate2D) async -> String {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            
            guard let placemark = placemarks.first else {
                return "Unknown"
            }
            
            // mesto
            if let locality = placemark.locality {
                if let cleanCity = locality.components(separatedBy: "-").first {
                    return cleanCity.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                return locality
            }
            
            // Okres
            if let subAdministrativeArea = placemark.subAdministrativeArea {
                return subAdministrativeArea
            }
            
            // kraj
            if let administrativeArea = placemark.administrativeArea {
                return administrativeArea
            }
            
            return ""
            
        } catch {
            print("Geocoding failed: \(error.localizedDescription)")
            return ""
        }
    }
}
