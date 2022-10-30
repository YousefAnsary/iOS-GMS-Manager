//
//  GMSGeocodingManager.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import GoogleMaps

public class GMSGeocodingManager {

    public weak var delegate: GMSGeocodingManagerDelegate?
    private let gmsGeocoder: GMSGeocoder
    private let debounceInterval: Double
    private var geocodingWorkItem: DispatchWorkItem?

    public init(debounceInterval: Double) {
        self.gmsGeocoder = GMSGeocoder()
        self.debounceInterval = debounceInterval
    }
    
    public func geocode(coordinates: CLLocation) {
        self.geocodingWorkItem?.cancel()
        self.geocodingWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.sendGeocodingRequest(coordinates: coordinates)
        })
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + self.debounceInterval,
                                                             execute: geocodingWorkItem!)
    }
    
    private func sendGeocodingRequest(coordinates: CLLocation) {
        self.gmsGeocoder.reverseGeocodeCoordinate(coordinates.coordinate) { [weak self] (data, err) in
            guard let data = data,
                  err == nil else {
                self?.delegate?.geocoding(failedWithError: err ?? GMSManagerUnknownError()); return
            }
            self?.geocodingResponseReceived(data)
        }
    }
    
    private func geocodingResponseReceived(_ data: GMSReverseGeocodeResponse) {
        let coordinates = data.firstResult()?.coordinate
        let country = data.firstResult()?.country
        let state = data.firstResult()?.administrativeArea
        let city = data.firstResult()?.locality
        let district = data.firstResult()?.subLocality
        let streetName = data.firstResult()?.thoroughfare
        let addresses = data.firstResult()?.lines
        let zipCode = data.firstResult()?.postalCode
        let coordinate = Coordinates(latitude: coordinates?.latitude,
                                     longitude: coordinates?.longitude)
        let data = GeocodingData(coordinates: coordinate,
                                 country: country,
                                 state: state,
                                 city: city,
                                 district: district,
                                 streetName: streetName,
                                 addresses: addresses,
                                 zipCode: zipCode)
        self.delegate?.geocoding(succeedWithData: data)
    }
}
