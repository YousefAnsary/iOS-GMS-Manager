//
//  GMSGeocodingManager.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import GoogleMaps

public class GMSGeocodingManager {

    private let gmsGeocoder: GMSGeocoder
    private let debounceInterval: Double
    private var geocodingWorkItem: DispatchWorkItem?

    public init(debounceInterval: Double) {
        self.gmsGeocoder = GMSGeocoder()
        self.debounceInterval = debounceInterval
    }
    
    public func geocode(coordinates: CLLocation,
                        completion: @escaping (Result<GeocodingData, Error>) -> Void) {
        self.geocodingWorkItem?.cancel()
        self.geocodingWorkItem = DispatchWorkItem(block: { [weak self] in
            self?.sendGeocodingRequest(coordinates: coordinates,
                                       completion: completion)
        })
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + self.debounceInterval,
                                                             execute: geocodingWorkItem!)
    }
    
    private func sendGeocodingRequest(coordinates: CLLocation,
                                      completion: @escaping (Result<GeocodingData, Error>) -> Void) {
        self.gmsGeocoder.reverseGeocodeCoordinate(coordinates.coordinate) { [weak self] (data, err) in
            guard let self = self,
                  let data = data,
                  err == nil else {
                completion(.failure(err ?? GMSManagerUnknownError()))
                return
            }
            let geocodingData = self.geocodingResponseReceived(data)
            completion(.success(geocodingData))
        }
    }
    
    private func geocodingResponseReceived(_ data: GMSReverseGeocodeResponse) -> GeocodingData {
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
        return GeocodingData(coordinates: coordinate,
                             country: country,
                             state: state,
                             city: city,
                             district: district,
                             streetName: streetName,
                             addresses: addresses,
                             zipCode: zipCode)
    }
}
