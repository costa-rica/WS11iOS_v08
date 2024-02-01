//
//  User.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import Foundation

class User:Codable {
    var id: String?
    var email: String?
    var password: String?
    var username: String?
    var token: String?
    var admin: Bool?
    var oura_token: String?
    var latitude:String?
    var longitude:String?
    var timezone:String?
}
