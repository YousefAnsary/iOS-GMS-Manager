//
//  UserLocationPermissionError.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

import Foundation

public struct UserLocationPermissionError: LocalizedError {

    public var errorDescription: String? {
        failureReason
    }

    public var failureReason: String? {
        "Location Disabled or Permission is not Granted, Guide user to grant location permission for your app"
    }

    /// A localized message describing how one might recover from the failure.
    public var recoverySuggestion: String? {
        "Guide user to grant location permission for your app"
    }
}
