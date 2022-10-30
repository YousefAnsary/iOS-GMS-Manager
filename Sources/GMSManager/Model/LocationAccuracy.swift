//
//  LocationAccuracy.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import CoreLocation

public enum LocationAccuracy {
    ///The highest possible accuracy that uses additional sensor data to facilitate navigation apps.
    case bestForNavigation
    /// The best level of accuracy available.
    case best
    /// Accurate to within ten meters of the desired target.
    case nearestTenMeters
    /// Accurate to within one hundred meters.
    case nearestHundredMeters
    /// Accurate to the nearest kilometer.
    case nearestKilometer
    /// Accurate to the nearest three kilometers.
    case nearestThreeKilometers
    /// The level of accuracy used when an app isn’t authorized for full accuracy location data.
    @available(iOS 14, *)
    case reduced
    
    public var value: Double {
        switch self {
        case .bestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .best:
            return kCLLocationAccuracyBest
        case .nearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        case .nearestHundredMeters:
            return kCLLocationAccuracyHundredMeters
        case .nearestKilometer:
            return kCLLocationAccuracyKilometer
        case .nearestThreeKilometers:
            return kCLLocationAccuracyThreeKilometers
        case .reduced:
            if #available(iOS 14.0, *) {
                return kCLLocationAccuracyReduced
            } else {
                // Should never reach here as this case is marked for iOS 14
                return -1
            }
        }
    }
}
