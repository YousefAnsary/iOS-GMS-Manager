//
//  Marker.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import UIKit

public struct Marker {
    
    public let id: String
    public let latitude, longitude: Double
    public let image: UIImage?
    public let customViewFactory: ((Marker) -> UIView)?
    
    public init(id: String,
                latitude: Double,
                longitude: Double,
                image: UIImage?) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.customViewFactory = nil
    }
    
    public init(id: String,
                latitude: Double,
                longitude: Double,
                customViewFactory: @escaping (Marker) -> UIView) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.image = nil
        self.customViewFactory = customViewFactory
    }
}
