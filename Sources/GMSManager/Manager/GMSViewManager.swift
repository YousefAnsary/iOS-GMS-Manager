//
//  GMSViewManager.swift
//  
//
//  Created by Youssef El-Ansary on 18/11/2022.
//

import UIKit

public protocol GMSViewManager {
    var customMarkerSize: CGSize { get set }
    var delegate: GMSViewManagerDelegate? { get set }
    func attachMap(toView view: UIView,
                   showCurrentLocationIndicator: Bool,
                   showLocateMeButton: Bool)
    func setAccuracy(_ accuracy: LocationAccuracy)
    func centerMapOnCurrentLocation()
    func setupLocateMeButtonInsets(_ insets: UIEdgeInsets)
    func setMapType(_ type: MapType)
    func configureStyle(fromJSONFile jsonURL: URL) throws
    func displayAndCenterCustomMarkersOnMap(_ markers: [Marker],
                                            markersCenteringPadding: Double)
    func displayCustomMarkersOnMap(_ markers: [Marker])
    func clearMarkers()
    func centerMapToShow(coordinates: [Coordinates], padding: CGFloat)
}
