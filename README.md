# iOS-GMS-Manager
Swift Package to help managing Google Maps Views in your app

### Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Map View Manager Usage](#map-view-manager-usage)
- [Places Search Manager Usage](#places-search-manager-usage)
- [Geocoding Manager Usage](#geocoding-manager-usage)

----

### Features

- [x] Embeds and Based on Google Maps & Google Places Swift Packaged found [here](https://github.com/YAtechnologies/GoogleMaps-SP)
- [x] Abstracted Interfaces for managing Google Map Views, Places Searching, Geodcoding

----

### Requirements
- Swift 4.2+
- Xcode 11+

----

### Installation

**Swift Package Manager**

```
.package(url: "https://github.com/YousefAnsary/iOS-GMS-Manager.git", from: "0.5.1")
```

----

### Map View Manager Usage

1- If you don't have GMS Key head to Google's developer portal to generate a one, instruction found [here](https://developers.google.com/maps/documentation/ios-sdk/get-api-key#add_key)

2- Provide your keys in AppDelegate.application(didFinishLaunchingWithOptions:) like so
```

func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
                    GMSManager.provideGMSKey("YOUR_KEY")
                    GMSManager.provideGMSPlacesKey("YOUR_KEY") // If you will use places services
}
```
<br/>

3- In the controller you need a map view, just put a UIView with the right constraints so we can attach the map view to it by calling following function and passing the default coordinates that map starts on and fallbacks to it if current location fetch failed when demanded, also you can pass a UIImage to be used as custom center marker if needed, nil otherwise
```
let defaultLocation = MapPosition(latitude: Double, longitude: Double, zoomLevel: Float)
let mapManager = GMSManager.viewManagerInstance(defaultLocation: defaultLocation, 
                                                markerImage: nil)
// in viewDidLoad
mapManager.attachMap(toView: myMapContainerView,
                     showCurrentLocationIndicator: true,
                     showLocateMeButton: true)
```
<br/>

4- use your mapManager instance to manage the style and the functionalities of your map, find its protocol below
```
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
```
5- Set the delegate of your mapManager by conforming to `GMSViewManagerDelegate` and setting `mapManager.delegate = self` , find delegate protocol below
```
public protocol GMSViewManagerDelegate: AnyObject {
    func locationUpdate(failedWithError error: Error) // Mandatory
    func mapView(idleAt position: Coordinates) // Optional
    func markerDidTapped(withID id: String) // Optional
    func didBeginLoading() // Optional
    func didEndLoading() // Optional
}
```

----

### Places Search Manager Usage

1- You must provide places service key as mentioned in first step <br/>
2- Initialize your instance passing the debounce interval before firing the request in seconds
(When user stops typing for X second request will be sent)
```
let placesSearchManager = GMSPlacesSearchService(debounceInterval: 0.5)
```
3- Search for suggestions related to sepcific keyword/user input
```
// Inside your Search Field delegate or where ever you want to start searching
placesSearchManager.search(for: "Your-Search-Keyword",
                           restrictingToCountries: ["au", "nz"], // nil by default (not restricted)
                           completion: { [weak self] (res: Result<[GMSSearchPrediction], Error>) in 
                               switch res {
                                  case .success(let results):
                                     print(results.map { $0.attributedFullText.string })
                                  case .failure(let error):
                                     print(error)
                               }
                           })
```
4- To fetch more details about one of the fetched suggestion (on user click for example)
```
placesSearchManager.fetchDetails(forPlace: myPrediction,
                                 completion: { [weak self] (res: Result<GMSSearchResult, Error>) in 
                                     switch res {
                                       case .success(let result):
                                         print(result.coordinate) // .name || .phoneNumber , ...
                                       case .failure(let error):
                                         print(error)
                                     }
                                 })
```
----

### Geocoding Manager Usage
1- You must provide service key as mentioned in first step <br/>
2- Initialize your instance passing the debounce interval before firing the request in seconds
(When user stops typing for X second request will be sent)
```
let geocodongManager = GMSGeocodingManager(debounceInterval: 0.5)
```
3- Start geocoding by pass your coordinates 
```
geocodongManager.geocode(coordinates: myCLLocation,
                         completion: { [weak self] (res: Result<GeocodingData, Error>) in 
                            switch res {
                               case .success(let result):
                                   print(result)
                               case .failure(let error):
                                   print(error)
                            }
                         })
```
----
```
public struct GeocodingData {
    public let coordinates: Coordinates?
    public let country: String?
    public let state: String?
    public let city: String?
    public let district: String?
    public let streetName: String?
    public let addresses: [String]?
    public let zipCode: String?
}
```
----
