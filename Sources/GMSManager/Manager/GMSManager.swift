
import UIKit
import GoogleMaps
import GooglePlaces

public class GMSManager {
    
    public static func provideGMSKey(_ key: String) {
        GMSServices.provideAPIKey(key)
    }
    
    public static func provideGMSPlacesKey(_ key: String) {
        GMSPlacesClient.provideAPIKey(key)
    }
    
    public static func viewManagerInstance(defaultLocation: MapPosition,
                                           markerImage: UIImage?) -> GMSViewManager {
        return GMSViewManagerImpl(defaultLocation: defaultLocation,
                                  markerImage: markerImage)
    }
}

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

class GMSViewManagerImpl: NSObject, GMSViewManager {
    
    // MARK: - Variables
    private(set) weak var mapView: GMSMapView?
    private let locationService: GMSManagerLocationService
    private let defaultLocation: MapPosition
    private let hasMarker: Bool
    private let markerImage: UIImage?
    private var customMarkerImageView: UIImageView?
    public var customMarkerSize = CGSize(width: 25, height: 25)
    weak var delegate: GMSViewManagerDelegate?
    
    // MARK: - Initializers
    init(defaultLocation: MapPosition, markerImage: UIImage?) {
        self.locationService = GMSManagerLocationService()
        self.defaultLocation = defaultLocation
        self.hasMarker = markerImage != nil
        self.markerImage = markerImage
        super.init()
        self.locationService.delegate = self
    }
    
    // MARK: - Basic Functionality
    public func attachMap(toView view: UIView,
                          showCurrentLocationIndicator: Bool,
                          showLocateMeButton: Bool) {
        let mapView = GMSMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.isMyLocationEnabled = showCurrentLocationIndicator
        mapView.settings.myLocationButton = showLocateMeButton
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        self.mapView = mapView
        self.fallbackToDefaultLocation()
        self.setupCustomMarker()
    }
    
    public func setAccuracy(_ accuracy: LocationAccuracy) {
        self.locationService.setAccuracy(accuracy)
    }
    
    public func centerMapOnCurrentLocation() {
        self.delegate?.didBeginLoading()
        self.locationService.requestWhenInUseAuthorization()
        self.locationService.requestLocation()
    }
    
    // MARK: - Customizations
    public func setupLocateMeButtonInsets(_ insets: UIEdgeInsets) {
        self.mapView?.padding = insets
    }
    
    public func setMapType(_ type: MapType) {
        self.mapView?.mapType = type
    }
    
    public func configureStyle(fromJSONFile jsonURL: URL) throws {
        mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: jsonURL)
    }
    
    // MARK: - Markers Drawing
    public func displayAndCenterCustomMarkersOnMap(_ markers: [Marker],
                                                   markersCenteringPadding: Double) {
        self.displayCustomMarkersOnMap(markers)
        let coordinates = markers.map {
            Coordinates(latitude: $0.latitude, longitude: $0.longitude)
        }
        self.centerMapToShow(coordinates: coordinates, padding: markersCenteringPadding)
    }
    
    public func displayCustomMarkersOnMap(_ markers: [Marker]) {
        markers.forEach {
            let position = CLLocationCoordinate2D(latitude: $0.latitude,
                                                  longitude: $0.longitude)
            let marker = GMSMarker(position: position)
            marker.iconView = $0.customViewFactory?($0)
            marker.icon = $0.image
            marker.userData = $0.id
            marker.map = self.mapView
        }
    }
    
    public func clearMarkers() {
        self.mapView?.clear()
    }
    
    public func centerMapToShow(coordinates: [Coordinates], padding: CGFloat) {
        let bounds = coordinates.reduce(GMSCoordinateBounds()) {
            $0.includingCoordinate(CLLocationCoordinate2D(latitude: $1.latitude, longitude: $1.longitude))
        }
        self.mapView?.animate(with: .fit(bounds, withPadding: padding))
    }
    
    // MARK: - Private Functions
    private func fallbackToDefaultLocation() {
        self.locationUpdated(withCoordinates: self.defaultLocation.getCLLocation())
    }
    
    private func setupCustomMarker() {
        guard self.hasMarker,
        let mapView = self.mapView,
        let markerImage = self.markerImage else { return }
        self.customMarkerImageView = UIImageView(image: markerImage)
        self.customMarkerImageView?.contentMode = .scaleAspectFit
        self.customMarkerImageView?.translatesAutoresizingMaskIntoConstraints = false
        mapView.addSubview(customMarkerImageView!)
        NSLayoutConstraint.activate([
            self.customMarkerImageView!.widthAnchor.constraint(equalToConstant: self.customMarkerSize.width),
            self.customMarkerImageView!.heightAnchor.constraint(equalToConstant: self.customMarkerSize.height),
            self.customMarkerImageView!.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            self.customMarkerImageView!.centerYAnchor.constraint(equalTo: mapView.centerYAnchor)
        ])
    }
}

// MARK: - Location Delegate
extension GMSViewManagerImpl: GMSManagerLocationServiceDelegate {
    
    public func locationPermissionDenied() {
        self.fallbackToDefaultLocation()
        self.delegate?.locationUpdate(failedWithError: UserLocationPermissionError())
        self.delegate?.didEndLoading()
    }
    
    public func locationUpdated(withCoordinates coordinates: CLLocation) {
        let coordinates = coordinates.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinates.latitude,
                                              longitude: coordinates.longitude,
                                              zoom: self.defaultLocation.zoomLevel)
        self.mapView?.camera = camera
        self.delegate?.didEndLoading()
    }
    
    public func locationUpdate(failedWithError error: Error) {
        self.fallbackToDefaultLocation()
        self.delegate?.locationUpdate(failedWithError: error)
        self.delegate?.didEndLoading()
    }
}

// MARK: - GMS Map View Delegate
extension GMSViewManagerImpl: GMSMapViewDelegate {
    
    public func mapView(_ mapView: GMSMapView,
                        idleAt position: GMSCameraPosition) {
        self.delegate?.mapView(idleAt: Coordinates(latitude: position.target.latitude,
                                                   longitude: position.target.longitude))
    }
    
    public func mapView(_ mapView: GMSMapView,
                        didTap marker: GMSMarker) -> Bool {
        guard let id = marker.userData as? String else { return false }
        self.delegate?.markerDidTapped(withID: id)
        return true
    }
}
