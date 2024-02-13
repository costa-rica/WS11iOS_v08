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
    var flagBackground=String()
    var flagDailyOnly: String {
        get {
            // Retrieve the value from UserDefaults, defaulting to "false" if not set
            return UserDefaults.standard.string(forKey: "flagDailyOnly") ?? "false"
        }
        set {
            // Save the new value to UserDefaults
            UserDefaults.standard.set(newValue, forKey: "flagDailyOnly")
        }
    }
    var userLocationManagerAuthStatus: String {
        // This computed property returns the string representation of the authorization status
        didSet {
            print("Authorization Status Updated: \(userLocationManagerAuthStatus)")
        }
    }

    override init() {
        userLocationManagerAuthStatus = LocationFetcher.string(for: locationManager.authorizationStatus)
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true // Enable background location updates
        locationManager.pausesLocationUpdatesAutomatically = false // Prevent automatic pausing
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
        print("*** Requested permission ***")
        locationManager.requestAlwaysAuthorization()
    }
    
    func startMonitoringLocationChanges() {
        DispatchQueue.global().async {
          if CLLocationManager.locationServicesEnabled() {
              self.flagBackground="background"
              self.locationManager.startMonitoringSignificantLocationChanges()
          }
        }
    }
    
    func stopMonitoringLocationChanges() {
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }

    
    func fetchLocation(completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
          if CLLocationManager.locationServicesEnabled() {
              self.flagBackground="foreground"
              switch self.locationManager.authorizationStatus {
              case .authorizedAlways, .authorizedWhenInUse:
                  self.locationFetchCompletion = completion // Store the completion handler
                  self.locationManager.requestLocation() // Asynchronously updates location
              default:
                  completion(false)
              }
          }
        }
    }
    
    
    // MARK: - File Handling
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // This method goes with appendLocationToFile
    private func pre_appendLocationToFile(locations: [CLLocation]){
        if let location = locations.last {
            currentLocation = location.coordinate
            // Append location to user_location.json
            
            // Create a DateFormatter
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Example format
            dateFormatter.timeZone = TimeZone.current // Set to current timezone
            
            // Get the current date and time in the local timezone
            let localDate = dateFormatter.string(from: Date())
            
            let locationData = [localDate, "\(location.coordinate.latitude)", "\(location.coordinate.longitude)","\(flagBackground)","\(flagDailyOnly)"]
            // The description of each position in the array
            // [local time, latitude, longitude, Collected in background, Collect once a day]
            appendLocationToFile(locationData)
            
            locationFetchCompletion?(true) // Call completion with true since location is updated
            locationFetchCompletion = nil // Clear the stored completion handler
        }
    }

    private func appendLocationToFile(_ locationData: [String]) {

        
//        // Replace the first element of locationData with the local date and time
//        var modifiedLocationData = locationData
//        modifiedLocationData[0] = localDate
        
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
                location.time = array[0]
                location.latitude = array[1]
                location.longitude = array[2]
                location.background = array.count > 3 ? array[3] : nil // Check for background flag
                location.dailyOnly = array.count > 4 ? array[4] : nil // Check for background flag
                return location
            }
            self.arryHistUserLocation = locations
            print("checkUserLocationJson success!")
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
        
        // Retrieve the last update date from persistent storage
        let lastUpdateDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as? Date ?? .distantPast
        let calendar = Calendar.current
        
        // if flagDailyOnly is set to true then check that not update was made to day. Otherwise, always add to user_location.json
        if flagDailyOnly=="true"{
            if !calendar.isDateInToday(lastUpdateDate) {
                pre_appendLocationToFile(locations: locations)
            }
        } else {
            pre_appendLocationToFile(locations: locations)
        }
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
    var time:String?
    var latitude:String?
    var longitude:String?
    var background:String?
    var dailyOnly:String?
}

class DictSendUserLocation:Codable{
    var user_location:[HistUserLocation]!
    var timestamp_utc:String!
    var location_permission:String!
    var location_reoccuring_permission:String!
}

class DictUpdate:Codable{
    var latitude:String!
    var longitude:String!
    var location_permission:String!
    var location_reoccuring_permission:String!
}
