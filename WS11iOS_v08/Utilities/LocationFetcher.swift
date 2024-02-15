//
//  LocationFetcher.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import Foundation
import CoreLocation


enum LocationFetcherError:Error{
    case failedDecode
    case somethingWentWrong
    var localizedDescription:String{
        switch self{
        case.failedDecode: return "Failed to decode"
        default:return "uhhh Idk?"
        }
    }
}

class LocationFetcher: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    private var locationFetchCompletion: ((Bool) -> Void)?
    var arryHistUserLocation:[HistUserLocation]?
    var userLocationManagerAuthStatus: String {
        // This computed property returns the string representation of the authorization status
        didSet {
            print(" SET: userLocationManagerAuthStatus --")
            print("Authorization Status Updated: \(userLocationManagerAuthStatus)")
        }
    }
    private let userDefaults = UserDefaults.standard
    private let updateInterval: TimeInterval = 86_400 // 24 hours in seconds
    
    override init() {
        userLocationManagerAuthStatus = LocationFetcher.string(for: locationManager.authorizationStatus)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true // Enable background location updates
        locationManager.pausesLocationUpdatesAutomatically = false // Prevent automatic pausing
        checkUserLocationJson { result in
            if result{
                print("arryHistUserLocation is populated")
                
            }
        }
    }
    // Convert CLLocationManager.AuthorizationStatus to a readable string
    private static func string(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Authorized Always"
        case .authorizedWhenInUse: return "Authorized When In Use"
        @unknown default: return "Unknown"
        }
    }
    func requestLocationPermission() {

        locationManager.requestAlwaysAuthorization()
    }
    func startMonitoringLocationChanges() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                self.locationManager.startMonitoringSignificantLocationChanges()
                print("############################")
                print("- START: monitoring location changes")
                print("############################")
            }
        }
    }
    func stopMonitoringLocationChanges() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
        print("-----------------------------------")
        print("- STOPPED: monitoring location changes")
        print("-----------------------------------")
    }
    
    
    func fetchLocation(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch self.locationManager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.locationFetchCompletion = completion // Store the completion handler
                    self.locationManager.requestLocation() // Asynchronously updates location
                    print("--- this path doesen't complete?")
//                    self.locationFetchCompletion?(true) // Call completion with true since location is updated
//                    self.locationFetchCompletion = nil // Clear the stored completion handler
//                    completion(true)
                default:
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
        print("--- this path doesen't complete? 2")
    }
    
    
    // MARK: - File Handling
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // This method goes with appendLocationToFile
    private func pre_appendLocationToFile(lastLocation: CLLocation){
        currentLocation = lastLocation.coordinate
        let locationData = ["\(getCurrentUtcDateString())", "\(lastLocation.coordinate.latitude)", "\(lastLocation.coordinate.longitude)"]
        appendLocationToFile(locationData)
        locationFetchCompletion?(true) // Call completion with true since location is updated
        locationFetchCompletion = nil // Clear the stored completion handler
    }
    
    private func appendLocationToFile(_ locationData: [String]) {
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("user_location.json")
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                // File exists, append data
                var currentData = try JSONDecoder().decode([[String]].self, from: Data(contentsOf: fileURL))
                //                currentData.append(modifiedLocationData)
                currentData.append(locationData)
                let updatedData = try JSONEncoder().encode(currentData)
                try updatedData.write(to: fileURL)
            } else {
                // File doesn't exist, create and write data
                //                let newData = try JSONEncoder().encode([modifiedLocationData])
                let newData = try JSONEncoder().encode([locationData])
                try newData.write(to: fileURL)
            }
            print("Location data saved with local time.")
        } catch {
            print("Failed to save location data: \(error.localizedDescription)")
        }
    }
    
    func checkUserLocationJson(completion: @escaping (Bool) -> Void) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let userJsonFile = documentsURL.appendingPathComponent("user_location.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            //            completion(.failure(LocationFetcherError.somethingWentWrong))
            print("checkUserLocationJson error: \(LocationFetcherError.somethingWentWrong)")
            completion(false)
            return
        }
        do {
            let jsonData = try Data(contentsOf: userJsonFile)
            let rawData = try JSONDecoder().decode([[String]].self, from: jsonData)
            let locations = rawData.map { array -> HistUserLocation in
                let location = HistUserLocation()
                location.dateTimeUtc = array[0]
                location.latitude = array[1]
                location.longitude = array[2]
                return location
            }
            self.arryHistUserLocation = locations
            completion(true)
        } catch {
            print("- failed to make userDict")
            print("checkUserLocationJson error: \(LocationFetcherError.failedDecode)")
            completion(false)
        }
    }
    
    
}

// MARK: - CLLocationManagerDelegate
extension LocationFetcher {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("*** acccessed didUpdateLocations ***")
        guard let lastLocation = locations.last else {
            print("* This is where we are stuck <---")
            return }
        let lastUpdateTimestamp = userDefaults.double(forKey: "lastUpdateTimestamp")
        let now = Date().timeIntervalSince1970
        if now - lastUpdateTimestamp >= updateInterval {
            print("* This is where we are stuck <--- 2")
            // Process new location here
            pre_appendLocationToFile(lastLocation: lastLocation)
            // Update the timestamp of the last processed update
            userDefaults.set(now, forKey: "lastUpdateTimestamp")
        } 
        else{
            print("--- should complete ???????")
            locationFetchCompletion?(true) // Call completion with true since location is updated
            locationFetchCompletion = nil // Clear the stored completion handler
        }
        print("Exited didUpdateLocations")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Update userLocationManagerAuthStatus when authorization status changes
        userLocationManagerAuthStatus = LocationFetcher.string(for: status)
        
        // Handle authorization status change if needed, for example:
        // - Start or stop location updates
        // - Show or hide location-related features
    }
}


class HistUserLocation:Codable{
    var dateTimeUtc:String?
    var latitude:String?
    var longitude:String?
}

class DictSendUserLocation:Codable{
    var user_location:[HistUserLocation]!
    var timestamp_utc:String!
}

//class DictUpdate:Codable{
//    var latitude:String!
//    var longitude:String!
//    var location_permission:String!
//    var location_reoccuring_permission:String!
//}
