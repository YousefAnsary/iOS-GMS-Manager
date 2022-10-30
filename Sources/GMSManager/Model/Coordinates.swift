//
//  Coordinates.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

public struct Coordinates {
    public let latitude, longitude: Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init?(latitude: Double?, longitude: Double?) {
        guard let latitude = latitude,
              let longitude = longitude else { return nil }
        self.init(latitude: latitude, longitude: longitude)
    }
}
