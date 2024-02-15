//
//  User.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import Foundation

class User: Codable {
    var id: String?
    var email: String?
    var password: String?
    var username: String?
    var token: String?
    var admin: Bool?
    var oura_token: String?
    var latitude: String?
    var longitude: String?
    var timezone: String?
    var location_permission: Bool?
    var location_reoccuring_permission: Bool?
    var last_location_date: String?
    
    // Custom keys to handle JSON decoding
    private enum CodingKeys: String, CodingKey {
        case id, email, password, username, token, admin, oura_token, latitude, longitude, timezone, location_permission, location_reoccuring_permission, last_location_date
    }
    
    // Custom initializer to decode
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        token = try container.decodeIfPresent(String.self, forKey: .token)
        oura_token = try container.decodeIfPresent(String.self, forKey: .oura_token)
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        last_location_date = try container.decodeIfPresent(String.self, forKey: .last_location_date)
        
        // Decode 'admin' and 'location_permission' as String and convert to Bool
        if let adminString = try container.decodeIfPresent(String.self, forKey: .admin) {
            admin = adminString.lowercased() == "true"
        } else {
            admin = try container.decodeIfPresent(Bool.self, forKey: .admin)
        }
        
        if let locationPermissionString = try container.decodeIfPresent(String.self, forKey: .location_permission) {
            location_permission = locationPermissionString.lowercased() == "true"
        } else {
            location_permission = try container.decodeIfPresent(Bool.self, forKey: .location_permission)
        }
        if let locationReoccuringPermissionString = try container.decodeIfPresent(String.self, forKey: .location_reoccuring_permission) {
            location_reoccuring_permission = locationReoccuringPermissionString.lowercased() == "true"
        } else {
            location_reoccuring_permission = try container.decodeIfPresent(Bool.self, forKey: .location_reoccuring_permission)
        }
    }
    
    // Designated initializer
    init(id: String? = "",
         email: String? = "",
         password: String? = "",
         username: String? = "",
         token: String? = "",
         admin: Bool? = false,
         oura_token: String? = "",
         latitude: String? = "",
         longitude: String? = "",
         timezone: String? = "",
         location_permission: Bool? = false,
         location_reoccuring_permission: Bool? = false,
         last_location_date: String? = ""){
        
        self.id = id
        self.email = email
        self.password = password
        self.username = username
        self.token = token
        self.admin = admin
        self.oura_token = oura_token
        self.latitude = latitude
        self.longitude = longitude
        self.timezone = timezone
        self.location_permission = location_permission
        self.location_reoccuring_permission = location_reoccuring_permission
        self.last_location_date = last_location_date
    }
    
}

extension User {
    // Encode all User properties as strings
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode all properties as strings
        try container.encode(id ?? "", forKey: .id)
        try container.encode(email ?? "", forKey: .email)
        try container.encode(password ?? "", forKey: .password)
        try container.encode(username ?? "", forKey: .username)
        try container.encode(token ?? "", forKey: .token)
        try container.encode(oura_token ?? "", forKey: .oura_token)
        try container.encode(latitude ?? "", forKey: .latitude)
        try container.encode(longitude ?? "", forKey: .longitude)
        try container.encode(timezone ?? "", forKey: .timezone)
        try container.encode(last_location_date ?? "", forKey: .last_location_date)
        
        // Convert booleans to strings
        try container.encode(admin?.description ?? "false", forKey: .admin)
        try container.encode(location_permission?.description ?? "false", forKey: .location_permission)
        try container.encode(location_reoccuring_permission?.description ?? "false", forKey: .location_reoccuring_permission)
    }
}

