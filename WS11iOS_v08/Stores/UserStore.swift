//
//  UserStore.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import Foundation

enum UserStoreError: Error {
    case failedDecode
    case failedToLogin
    case failedToRegister
    case failedToUpdateUser
    case failedToRecieveServerResponse
    case failedToRecievedExpectedResponse
    case fileNotFound
    case serverError(statusCode: Int)
    var localizedDescription: String {
        switch self {
        case .failedDecode: return "Failed to decode response."
        case .fileNotFound: return "What Sticks API could not find the dashboard data on the server."
        default: return "What Sticks main server is not responding."
        }
    }
}

class UserStore {
    let fileManager:FileManager
    let documentsURL:URL
    var user = User(){
        didSet{
            if rememberMe {
                writeObjectToJsonFile(object: user, filename: "user.json")
            }
        }
    }
    var arryDataSourceObjects:[DataSourceObject]?
    var boolDashObjExists:Bool!
    var boolMultipleDashObjExist:Bool!
    var arryDashboardTableObjects=[DashboardTableObject](){
        didSet{
            guard let unwp_pos = currentDashboardObjPos else {return}
            if arryDashboardTableObjects.count > currentDashboardObjPos{
                currentDashboardObject = arryDashboardTableObjects[unwp_pos]
                // error occurs line above. Error: out of range
            }
        }
    }
    var currentDashboardObject:DashboardTableObject?
    var currentDashboardObjPos: Int!
    var existing_emails = [String]()
    var urlStore:URLStore!
    var requestStore:RequestStore!
    var rememberMe = false
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    init() {
        self.user = User()
        self.fileManager = FileManager.default
        self.documentsURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func callUpdateUser(completion: @escaping (Result<String, Error>) -> Void) {
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .update_user, body: ["timezone":user.timezone])
        let task = session.dataTask(with: request) { data, response, error in
            guard let unwrappedData = data else {
                print("no data response")
                completion(.failure(UserStoreError.failedToRecieveServerResponse))
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                    print("json serialized well")
                    if let message = jsonResult["message"] as? String {
                        OperationQueue.main.addOperation {
                            completion(.success(message))
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToUpdateUser))
                        }
                    }
                } else {
                    throw UserStoreError.failedDecode
                }
            } catch {
                print("---- UserStore.failedToUpdateUser: Failed to read response")
                completion(.failure(UserStoreError.failedDecode))
            }
        }
        task.resume()
    }
    func callRegisterNewUser(email: String, password: String,lat:Double,lon:Double, completion: @escaping (Result<[String: String], Error>) -> Void) {
        
        let latString = String(lat)
        let lonString = String(lon)
        
        print("- registerNewUser accessed")
        let request = requestStore.createRequestWithTokenAndBody(endPoint: .register, body: ["new_email":email, "new_password":password, "lat":latString,"lon":lonString])
        let task = session.dataTask(with: request) { data, response, error in
            guard let unwrappedData = data else {
                print("no data response")
                completion(.failure(UserStoreError.failedToRecieveServerResponse))
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                    print("json serialized well")
                    if let id = jsonResult["id"] as? String {
                        print("json serialized well - doing better")
                        OperationQueue.main.addOperation {
                            completion(.success(["id": id]))
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRegister))
                        }
                    }
                } else {
                    throw UserStoreError.failedDecode
                }
            } catch {
                print("---- UserStore.registerNewUser: Failed to read response")
                completion(.failure(UserStoreError.failedDecode))
            }
        }
        task.resume()
    }
    func callLoginUser(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        let result = requestStore.createRequestLogin(email: email, password: password)
        
        switch result {
        case .success(let request):
            let task = session.dataTask(with: request) { (data, response, error) in
                // Handle the task's completion here as before
                guard let unwrapped_data = data else {
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.failedToRecieveServerResponse))
                    }
                    return
                }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonUser = try jsonDecoder.decode(User.self, from: unwrapped_data)
                    OperationQueue.main.addOperation {
                        completion(.success(jsonUser))
                    }
                } catch {
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.failedToLogin))
                    }
                }
            }
            task.resume()
            
        case .failure(let error):
            // Handle the error here
            print("* error encodeing from reqeustStore.createRequestLogin")
            OperationQueue.main.addOperation {
                completion(.failure(error))
            }
        }
    }
    func callDeleteUser(completion: @escaping (Result<[String: String], Error>) -> Void) {
        print("- in callDeleteAppleHealthData")
        let request = requestStore.createRequestWithToken(endpoint: .delete_user)
        let task = requestStore.session.dataTask(with: request) { data, response, error in
            // Handle potential error from the data task
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("- callDeleteUser: failure response: \(error)")
                }
                return
            }
            guard let unwrapped_data = data else {
                // No data scenario
                DispatchQueue.main.async {
                    completion(.failure(URLError(.badServerResponse)))
                    print("- callDeleteUser: failure response: \(URLError(.badServerResponse))")
                }
                return
            }
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: unwrapped_data, options: []) as? [String: String] {
                    DispatchQueue.main.async {
                        completion(.success(jsonResult))
                        print("- callDeleteUser: Successful response: \(jsonResult)")
                    }
                } else {
                    // Data is not in the expected format
                    DispatchQueue.main.async {
                        completion(.failure(URLError(.cannotParseResponse)))
                        print("- callDeleteUser: failure response: \(URLError(.cannotParseResponse))")
                    }
                }
            } catch {
                // Data parsing error
                DispatchQueue.main.async {
                    completion(.failure(error))
                    print("- callDeleteUser: failure response: \(error)")
                }
            }
        }
        task.resume()
    }
    func updateDataSourceObject(arry:[DataSourceObject]){
        self.arryDataSourceObjects = arry
    }
    func callSendDataSourceObjects(completion:@escaping (Result<Bool,Error>) -> Void){
        let request = requestStore.createRequestWithToken(endpoint: .send_data_source_objects)
        let task = requestStore.session.dataTask(with: request) { data, urlResponse, error in
            guard let unwrapped_data = data else {
                OperationQueue.main.addOperation {
                    completion(.failure(UserStoreError.failedToRecieveServerResponse))
                }
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                let jsonArryDataSourceObj = try jsonDecoder.decode([DataSourceObject].self, from: unwrapped_data)
                OperationQueue.main.addOperation {
                    self.writeObjectToJsonFile(object: jsonArryDataSourceObj, filename: "arryDataSourceObjects.json")
                    self.updateDataSourceObject(arry: jsonArryDataSourceObj)
                    completion(.success(true))
                }
            } catch {
                print("did not get expected response from WSAPI - probably no file for user")
                OperationQueue.main.addOperation {
                    completion(.failure(UserStoreError.failedToRecievedExpectedResponse))
                }
            }
        }
        task.resume()
    }
    func updateDashboardTableObject(arry:[DashboardTableObject]){
        self.arryDashboardTableObjects = arry
        self.currentDashboardObjPos = 0
        self.currentDashboardObject = self.arryDashboardTableObjects[self.currentDashboardObjPos]
        self.boolDashObjExists=true
        if self.arryDashboardTableObjects.count > 1 {
            self.boolMultipleDashObjExist = true
        } else {
            self.boolMultipleDashObjExist = false
        }
    }
    func callSendDashboardTableObjects(completion: @escaping (Result<Bool, Error>) -> Void) {
        let request = requestStore.createRequestWithToken(endpoint: .send_dashboard_table_objects)
        let task = requestStore.session.dataTask(with: request) { data, urlResponse, error in
            // Check for network errors
            if let error = error {
                OperationQueue.main.addOperation {
                    completion(.failure(error))
                }
                return
            }
            
            // Check for HTTP status code
            if let httpResponse = urlResponse as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    // Handle success case
                    guard let unwrappedData = data else {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRecieveServerResponse))
                        }
                        return
                    }
                    do {
                        let jsonDecoder = JSONDecoder()
                        let jsonArryDashboardTableObj = try jsonDecoder.decode([DashboardTableObject].self, from: unwrappedData)
                        OperationQueue.main.addOperation {
                            self.writeObjectToJsonFile(object: jsonArryDashboardTableObj, filename: "arryDashboardTableObjects.json")
                            self.updateDashboardTableObject(arry: jsonArryDashboardTableObj)
                            completion(.success(true))
                        }
                    } catch {
                        OperationQueue.main.addOperation {
                            completion(.failure(UserStoreError.failedToRecievedExpectedResponse))
                        }
                    }
                case 404:
                    // Handle file not found case
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.fileNotFound))
                    }
                default:
                    // Handle other HTTP errors
                    OperationQueue.main.addOperation {
                        completion(.failure(UserStoreError.serverError(statusCode: httpResponse.statusCode)))
                    }
                }
            }
        }
        task.resume()
    }
}

// writing json files
extension UserStore{
    func writeObjectToJsonFile<T: Encodable>(object: T, filename: String) {
        var jsonData: Data!
        do {
            let jsonEncoder = JSONEncoder()
            jsonData = try jsonEncoder.encode(object)
        } catch {
            print("Failed to encode json: \(error)")
            return
        }
        
        let jsonFileURL = self.documentsURL.appendingPathComponent(filename)
        do {
            try jsonData.write(to: jsonFileURL)
        } catch {
            print("Error writing to file: \(error)")
        }
    }
    func deleteJsonFile(filename:String){
        let jsonFileURL = self.documentsURL.appendingPathComponent(filename)
        do {
            try fileManager.removeItem(at: jsonFileURL)
            self.boolDashObjExists=false
            self.boolMultipleDashObjExist=false
        } catch {
            print("No no \(filename) file exists")
        }
    }// "arryDashboardTableObjects.json", "arryDataSourceObjects.json", "user.json"
    
    func checkDataSourceJson(completion: @escaping (Result<Bool,Error>) -> Void){
        
        let userJsonFile = documentsURL.appendingPathComponent("arryDataSourceObjects.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            completion(.failure(UserStoreError.failedDecode))
            return
        }
        do{
                let jsonData = try Data(contentsOf: userJsonFile)
                let decoder = JSONDecoder()
                //            self.arryDataSourceObjects = try decoder.decode([DataSourceObject].self, from:jsonData)
                let arry = try decoder.decode([DataSourceObject].self, from:jsonData)
            OperationQueue.main.addOperation {
                self.updateDataSourceObject(arry: arry)
                completion(.success(true))
            }
        } catch {
            print("- failed to make userDict");
            completion(.failure(UserStoreError.failedDecode))
        }
    }
    
    func checkDashboardJson(completion: @escaping (Result<Bool,Error>) -> Void){
        
        let userJsonFile = documentsURL.appendingPathComponent("arryDashboardTableObjects.json")
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            print("-in UserStore file not found -")
            self.boolDashObjExists = false
            completion(.failure(UserStoreError.fileNotFound))
            return
        }
        do{
            let jsonData = try Data(contentsOf: userJsonFile)
            let decoder = JSONDecoder()
            let arry = try decoder.decode([DashboardTableObject].self, from:jsonData)
//            self.boolDashObjExists = true
            OperationQueue.main.addOperation {
                self.updateDashboardTableObject(arry: arry)
                completion(.success(true))
            }
            
        } catch {
            print("- failed to make userDict");
            self.boolDashObjExists = false
            completion(.failure(UserStoreError.failedDecode))
        }
//        completion(.success(self.arryDashboardTableObjects))
        
    }
    
    func checkUserJson(completion: (Result<User,Error>) -> Void){
        
        let userJsonFile = documentsURL.appendingPathComponent("user.json")
        
        guard fileManager.fileExists(atPath: userJsonFile.path) else {
            completion(.failure(UserStoreError.failedDecode))
            return
        }
        var user:User?
        do{
            let jsonData = try Data(contentsOf: userJsonFile)
            let decoder = JSONDecoder()
            user = try decoder.decode(User.self, from:jsonData)
        } catch {
            print("- failed to make userDict");
            completion(.failure(UserStoreError.failedDecode))
        }
        guard let unwrapped_user = user else {
            print("unwrapped_userDict failed")
            completion(.failure(UserStoreError.failedDecode))
            return
        }
        completion(.success(unwrapped_user))
        
    }
    
}

