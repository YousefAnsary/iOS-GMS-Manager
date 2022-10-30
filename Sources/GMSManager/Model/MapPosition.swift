//
//  MapPosition.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import CoreLocation

public struct MapPosition {
    
    public let latitude, longitude : Double
    public let zoomLevel: Float
    
    public init(latitude: Double, longitude: Double, zoomLevel: Float) {
        self.latitude = latitude
        self.longitude = longitude
        self.zoomLevel = zoomLevel
    }
    
    func getCLLocation() -> CLLocation {
        return CLLocation(latitude: self.latitude,
                          longitude: self.longitude)
    }
}
