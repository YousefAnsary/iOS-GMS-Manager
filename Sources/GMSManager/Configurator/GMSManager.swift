
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
