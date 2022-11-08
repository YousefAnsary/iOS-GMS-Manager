//
//  GMSViewManagerDelegate.swift
//  
//
//  Created by Youssef El-Ansary on 29/10/2022.
//

public protocol GMSViewManagerDelegate: AnyObject {
    func locationUpdate(failedWithError error: Error)
    func mapView(idleAt position: Coordinates)
    func markerDidTapped(withID id: String)
    func didBeginLoading()
    func didEndLoading()
}

public extension GMSViewManagerDelegate {
    func mapView(idleAt position: Coordinates) {}
    func markerDidTapped(withID id: String) {}
    func didBeginLoading() {}
    func didEndLoading() {}
}
