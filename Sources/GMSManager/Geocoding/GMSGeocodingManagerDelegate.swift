//
//  GMSGeocodingManagerDelegate.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

public protocol GMSGeocodingManagerDelegate: AnyObject {
    func geocoding(failedWithError error: Error)
    func geocoding(succeedWithData data: GeocodingData)
}
