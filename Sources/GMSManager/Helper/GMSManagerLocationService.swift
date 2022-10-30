//
//  GMSManagerLocationService.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import CoreLocation

protocol GMSManagerLocationServiceDelegate: AnyObject {
    func locationPermissionDenied()
    func locationUpdated(withCoordinates coordinates: CLLocation)
    func locationUpdate(failedWithError error: Error)
}

class GMSManagerLocationService: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    weak var delegate: GMSManagerLocationServiceDelegate?
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
    }
    
    func setAccuracy(_ accuracy: LocationAccuracy) {
        self.locationManager.desiredAccuracy = accuracy.value
    }
    
    func requestWhenInUseAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    func requestLocation() {
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        let coordinates = CLLocation(latitude: location.latitude, longitude: location.longitude)
        self.delegate?.locationUpdated(withCoordinates: coordinates)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            self.delegate?.locationPermissionDenied()
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            assert(false, "Unhandled Location Permission Status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        self.delegate?.locationUpdate(failedWithError: error)
    }
}
