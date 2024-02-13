//
//  LocationFetcher.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import Foundation
import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    // Store the completion handler to call later
    private var locationFetchCompletion: ((Bool) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermission() {
        print("*** Requested permission ***")
//        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
    }

    func fetchLocation(completion: @escaping (Bool) -> Void) {
        guard CLLocationManager.locationServicesEnabled() else {
            completion(false)
            return
        }
        
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationFetchCompletion = completion // Store the completion handler
            locationManager.requestLocation() // Asynchronously updates location
        default:
            completion(false)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            
            currentLocation = location.coordinate
            if let unwp_curLcoaiton = currentLocation{
                print("* -- LocationFetcher got location: \(unwp_curLcoaiton.latitude), \(unwp_curLcoaiton.longitude)")
            }
            locationFetchCompletion?(true) // Call completion with true since location is updated
            locationFetchCompletion = nil // Clear the stored completion handler
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        locationFetchCompletion?(false) // Optionally, call completion with false on failure
        locationFetchCompletion = nil // Clear the stored completion handler
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}




//class LocationFetcher: NSObject, CLLocationManagerDelegate {
//    var userLocation:CLLocationCoordinate2D!
//    private let locationManager = CLLocationManager()
//    private var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
//
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//    }
//
//    func fetchLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
//        self.completion = completion
//        locationManager.requestLocation() // Request location once
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            completion?(.success(location.coordinate))
//        } else {
//            completion?(.failure(NSError(domain: "LocationError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Location data is unavailable."])))
//        }
//        // Reset the completion handler to nil to avoid retaining it longer than necessary
//        self.completion = nil
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        completion?(.failure(error))
//        // Reset the completion handler to nil to avoid retaining it longer than necessary
//        self.completion = nil
//    }
//}
