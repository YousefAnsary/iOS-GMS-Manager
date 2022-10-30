//
//  GMSConfigurator.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import GoogleMaps
import GooglePlaces

public class GMSConfigurator {
    
    public static func provideGMSKey(_ key: String) {
        GMSServices.provideAPIKey(key)
    }
    
    public static func provideGMSPlacesKey(_ key: String) {
        GMSPlacesClient.provideAPIKey(key)
    }
}
