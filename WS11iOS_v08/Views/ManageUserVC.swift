//
//  ManageUserVC.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import UIKit

//class ManageUserVC: TemplateVC, UIPickerViewDelegate, UIPickerViewDataSource{
class ManageUserVC: TemplateVC{
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var healthDataStore:HealthDataStore!
    var appleHealthDataFetcher: AppleHealthDataFetcher!
    var locationFetcher:LocationFetcher!
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    var lblFindSettingsScreenForAppleHealthPermission = UILabel()
    var lblPermissionsTitle = UILabel()
    
    let vwLineLocationDayWeather=UIView()
    let lblLocationDayWeatherTitle = UILabel()
    let lblLocationDayWeatherDetails = UILabel()
    let stckVwLocationDayWeather=UIStackView()
    let lblLocationDayWeatherSwitch=UILabel()
    let swtchLocationDayWeather = UISwitch()
    var btnUpdate = UIButton()
    var updateDict:[String:String] = [:]
    
    let lineViewDeleteUser = UIView()
    let lblDeleteUser=UILabel()
    var btnDeleteUser=UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupIsDev(urlStore: requestStore.urlStore)
        self.lblUsername.text = userStore.user.username
        self.lblScreenName.text = "Account"
        
        setup_scrollView()
        setupContent()
        setup_lblFindSettingsScreenForAppleHealthPermission()
        setup_locationDayWeather()
        setup_btnDeleteUser()
        
    }
    
    func setup_scrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints=false
        scrollView.accessibilityIdentifier = "scrollView"
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: vwFooter.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }
    private func setupContent() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Example content view constraints
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            // Important for horizontal scrolling
            // Set the contentView's height constraint to be greater than or equal to the scrollView's height for vertical scrolling if needed
        ])
    }
    
    
    func setup_lblFindSettingsScreenForAppleHealthPermission(){
        
        lblPermissionsTitle.accessibilityIdentifier="lblPermissionsTitle"
        lblPermissionsTitle.translatesAutoresizingMaskIntoConstraints = false
        lblPermissionsTitle.text = "Apple Health Permissions"
        lblPermissionsTitle.font = UIFont(name: "ArialRoundedMTBold", size: 25)
        lblPermissionsTitle.numberOfLines=0
        contentView.addSubview(lblPermissionsTitle)
        
        lblFindSettingsScreenForAppleHealthPermission.accessibilityIdentifier="lblFindSettingsScreenForAppleHealthPermission"
        lblFindSettingsScreenForAppleHealthPermission.translatesAutoresizingMaskIntoConstraints=false
        let text_for_message = "Go to Settings > Health > Data Access & Devices > WhatSticks11iOS to grant access.\n\nFor this app to work properly please make sure all data types are allowed."
        lblFindSettingsScreenForAppleHealthPermission.text = text_for_message
        lblFindSettingsScreenForAppleHealthPermission.numberOfLines = 0
        contentView.addSubview(lblFindSettingsScreenForAppleHealthPermission)
        
        NSLayoutConstraint.activate([
            lblPermissionsTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: heightFromPct(percent: 3)),
            lblPermissionsTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            lblPermissionsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            
            lblFindSettingsScreenForAppleHealthPermission.topAnchor.constraint(equalTo: lblPermissionsTitle.bottomAnchor, constant: heightFromPct(percent: 5)),
            lblFindSettingsScreenForAppleHealthPermission.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            lblFindSettingsScreenForAppleHealthPermission.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
        ])
    }
    
    private func setup_locationDayWeather() {
        vwLineLocationDayWeather.accessibilityIdentifier = "vwLineLocationDayWeather"
        vwLineLocationDayWeather.translatesAutoresizingMaskIntoConstraints = false
        vwLineLocationDayWeather.backgroundColor = UIColor(named: "lineColor")
        contentView.addSubview(vwLineLocationDayWeather)
        
        lblLocationDayWeatherTitle.accessibilityIdentifier="lblLocationDayWeatherTitle"
        lblLocationDayWeatherTitle.text = "Location Weather Tracking"
        lblLocationDayWeatherTitle.translatesAutoresizingMaskIntoConstraints=false
        lblLocationDayWeatherTitle.font = UIFont(name: "ArialRoundedMTBold", size: 25)
        lblLocationDayWeatherTitle.numberOfLines = 0
        contentView.addSubview(lblLocationDayWeatherTitle)
        
        lblLocationDayWeatherDetails.accessibilityIdentifier="lblLocationDayWeatherDetails"
        lblLocationDayWeatherDetails.text = "Allow What Sticks (WS) to collect your location to provide weather and timezone calculations for impacts on sleep and exercise. \n\nTurning this on will allow WS to collect your location daily."
        lblLocationDayWeatherDetails.translatesAutoresizingMaskIntoConstraints=false
        lblLocationDayWeatherDetails.numberOfLines = 0
        contentView.addSubview(lblLocationDayWeatherDetails)
        
        stckVwLocationDayWeather.accessibilityIdentifier="stckVwLocationDayWeather"
        stckVwLocationDayWeather.translatesAutoresizingMaskIntoConstraints=false
        stckVwLocationDayWeather.spacing = 5
        stckVwLocationDayWeather.axis = .horizontal
        contentView.addSubview(stckVwLocationDayWeather)
        
        lblLocationDayWeatherSwitch.accessibilityIdentifier="lblLocationDayWeatherSwitch"
        lblLocationDayWeatherSwitch.translatesAutoresizingMaskIntoConstraints=false
        stckVwLocationDayWeather.addArrangedSubview(lblLocationDayWeatherSwitch)
        
        swtchLocationDayWeather.accessibilityIdentifier = "swtchLocationDayWeather"
        swtchLocationDayWeather.translatesAutoresizingMaskIntoConstraints = false
        swtchLocationDayWeather.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        
        stckVwLocationDayWeather.addArrangedSubview(swtchLocationDayWeather)
        
        print("----> locationFetcher.userLocationManagerAuthStatus: \(locationFetcher.userLocationManagerAuthStatus)")
        
        if locationFetcher.userLocationManagerAuthStatus == "Denied"{
            print("*** accessed ?")
            swtchLocationDayWeather.isOn=false
            locationFetcher.stopMonitoringLocationChanges()
            
        } else {
            // Set Location Switch
            if let unwp_user_loc_permission = userStore.user.location_reoccuring_permission  {
                swtchLocationDayWeather.isOn = unwp_user_loc_permission
                if unwp_user_loc_permission{
                    if locationFetcher.userLocationManagerAuthStatus == "Authorized Always"{
                        locationFetcher.startMonitoringLocationChanges()
                    } else {
                        locationFetcher.stopMonitoringLocationChanges()
                    }
                }
            }
        }

        setLocationSwitchLabelText()
        
        NSLayoutConstraint.activate([
            vwLineLocationDayWeather.topAnchor.constraint(equalTo: lblFindSettingsScreenForAppleHealthPermission.bottomAnchor, constant: heightFromPct(percent: 5)),
            vwLineLocationDayWeather.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            vwLineLocationDayWeather.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            vwLineLocationDayWeather.heightAnchor.constraint(equalToConstant: 1),
            
            lblLocationDayWeatherTitle.topAnchor.constraint(equalTo: vwLineLocationDayWeather.bottomAnchor, constant: heightFromPct(percent: 2)),
            lblLocationDayWeatherTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lblLocationDayWeatherTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            lblLocationDayWeatherDetails.topAnchor.constraint(equalTo: lblLocationDayWeatherTitle.bottomAnchor, constant: heightFromPct(percent: 2)),
            lblLocationDayWeatherDetails.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lblLocationDayWeatherDetails.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            stckVwLocationDayWeather.topAnchor.constraint(equalTo: lblLocationDayWeatherDetails.bottomAnchor, constant: heightFromPct(percent: 2)),
            stckVwLocationDayWeather.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: widthFromPct(percent: -2)),
        ])
    }
    
    
    func setup_btnDeleteUser(){
        lineViewDeleteUser.backgroundColor = UIColor(named: "lineColor")
        contentView.addSubview(lineViewDeleteUser)
        lineViewDeleteUser.translatesAutoresizingMaskIntoConstraints = false
        
        lblDeleteUser.accessibilityIdentifier="lblDeleteUser"
        lblDeleteUser.text = "Delete Account"
        lblDeleteUser.translatesAutoresizingMaskIntoConstraints=false
        lblDeleteUser.font = UIFont(name: "ArialRoundedMTBold", size: 25)
        lblDeleteUser.numberOfLines = 0
        contentView.addSubview(lblDeleteUser)
        
        btnDeleteUser.translatesAutoresizingMaskIntoConstraints=false
        btnDeleteUser.accessibilityIdentifier="btnDeleteUser"
        btnDeleteUser.addTarget(self, action: #selector(self.touchDown(_:)), for: .touchDown)
        btnDeleteUser.addTarget(self, action: #selector(touchUpInside_btnDeleteUser(_:)), for: .touchUpInside)
        btnDeleteUser.backgroundColor = .systemRed
        btnDeleteUser.layer.cornerRadius = 10
        btnDeleteUser.setTitle(" Delete Account ", for: .normal)
        contentView.addSubview(btnDeleteUser)
        
        NSLayoutConstraint.activate([
            lineViewDeleteUser.bottomAnchor.constraint(equalTo: swtchLocationDayWeather.bottomAnchor, constant: heightFromPct(percent: 5)),
            lineViewDeleteUser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lineViewDeleteUser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lineViewDeleteUser.heightAnchor.constraint(equalToConstant: 1), // Set line thickness
            
            lblDeleteUser.topAnchor.constraint(equalTo: lineViewDeleteUser.bottomAnchor, constant: heightFromPct(percent: 2)),
            lblDeleteUser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: 2)),
            lblDeleteUser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            
            btnDeleteUser.topAnchor.constraint(equalTo: lblDeleteUser.bottomAnchor, constant: heightFromPct(percent:4)),
            btnDeleteUser.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            btnDeleteUser.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            btnDeleteUser.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: heightFromPct(percent: -2)),
        ])
    }
    
    func manageLocationCollection(){
        print("- accessed manageLocationCollection")
        if locationFetcher.userLocationManagerAuthStatus == "Authorized Always"{
//            print("- accessed manageLocationCollection 4")
            locationFetcher.fetchLocation { locationExists in
//                print("- accessed manageLocationCollection 2")
                if locationExists{
                    if let unwp_lat = self.locationFetcher.currentLocation?.latitude,
                       let unwp_lon = self.locationFetcher.currentLocation?.longitude{
                        let updateDict = ["latitude":String(unwp_lat),"longitude":String(unwp_lon),"location_permission":"True","location_reoccuring_permission":"True"]
                        self.sendUpdateDictToApi(updateDict: updateDict)
                    }
                    else {
                        let updateDict = ["location_permission":"True","location_reoccuring_permission":"True"]
                        self.sendUpdateDictToApi(updateDict: updateDict)
                        
                    }
                }
                else {
                    let updateDict = ["location_permission":"True","location_reoccuring_permission":"True"]
                    self.sendUpdateDictToApi(updateDict: updateDict)
                }
            }
        }
        else if locationFetcher.userLocationManagerAuthStatus == "Authorized When In Use" {
//            print("- 3 accessed manageLocationCollection")
            locationFetcher.fetchLocation { locationExists in
//                print("- 7 accessed manageLocationCollection")
                if locationExists{
                    if let unwp_lat = self.locationFetcher.currentLocation?.latitude,
                       let unwp_lon = self.locationFetcher.currentLocation?.longitude{
                        let updateDict = ["latitude":String(unwp_lat),"longitude":String(unwp_lon),"location_permission":"True","location_reoccuring_permission":"False"]
                        
                        self.userStore.callUpdateUser(endPoint: .update_user_location_with_lat_lon, updateDict: updateDict) { resultString in
//                            print("- 9 accessed manageLocationCollection")
                            switch resultString{
                            case .success(_):
//                                print("- 10 accessed manageLocationCollection")
                                DispatchQueue.main.async{
//                                    print("** --> label should have changed")
                                    self.removeSpinner()
//                                    self.lblLocationDayWeatherSwitch.text = "Track Location (\(getCurrentLocalDateString())): "
                                    self.setLocationSwitchLabelText()
                                }
                                self.templateAlert(alertTitle: "Success!", alertMessage: "")
                            case let .failure(error):
                                self.removeSpinner()
                                self.templateAlert(alertTitle: "Unsuccessful update", alertMessage: error.localizedDescription)
                            }
                        }
                    }
                }
            }
            let updateDict = ["location_permission":"True","location_reoccuring_permission":"False"]
            self.sendUpdateDictToApi(updateDict: updateDict)
            setLocationSwitchLabelText()
        }
        
        else {
            self.removeSpinner()
            self.swtchLocationDayWeather.isOn=false
            // Set Location Label
            self.setLocationSwitchLabelText()
//            let initialSwitchStateText = self.swtchLocationDayWeather.isOn ? "on" : "off"
//            self.lblLocationDayWeatherSwitch.text = "Track Location (\(initialSwitchStateText)): "
            self.templateAlert(alertTitle: "", alertMessage: "For better calculations go to Setting and set Location permissions to Always")
        }
        
    }
    func setLocationSwitchLabelText(){

        if swtchLocationDayWeather.isOn{
            if locationFetcher.userLocationManagerAuthStatus == "Authorized Always"{
                lblLocationDayWeatherSwitch.text = "Track Location (Once Daily): "
                self.locationFetcher.startMonitoringLocationChanges()
            }
            else if let unwp_last_date = userStore.user.last_location_date,
                    let unwp_timezone = userStore.user.timezone {
                if unwp_timezone != "Etc/GMT"{
                    lblLocationDayWeatherSwitch.text = "Track Location (\(unwp_last_date)): "
                } else {
                    lblLocationDayWeatherSwitch.text = "Track Location (Restricted): "
                }
            } else {
                lblLocationDayWeatherSwitch.text = "Track Location (Restricted): "
            }
        } else {
            lblLocationDayWeatherSwitch.text = "Track Location (off): "
            locationFetcher.stopMonitoringLocationChanges()
        }
    }
    
    func sendUpdateDictToApi(updateDict:[String:String]){
        self.userStore.callUpdateUser(endPoint: .update_user_location_with_lat_lon, updateDict: updateDict) { resultString in
            switch resultString{
            case .success(_):
                DispatchQueue.main.async{
                    self.removeSpinner()
                    self.swtchLocationDayWeather.isOn=true
                    self.setLocationSwitchLabelText()
                }
                
                self.templateAlert(alertTitle: "Success!", alertMessage: "")
            case let .failure(error):
                self.removeSpinner()
                self.setLocationSwitchLabelText()
                self.templateAlert(alertTitle: "Unsuccessful update", alertMessage: error.localizedDescription)
            }
        }
    }
    
    /* Objc Methods*/
    @objc private func switchValueChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            self.showSpinner()
            manageLocationCollection()
            
        } else {
            // Are you sure alert; if yes, then sends notification to WSAPI
            alertTurnOffLocationTrackingConfirmation()
        }
    }
    
    
    @objc func touchUpInside_btnDeleteUser(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("delete user api call")
        alertDeleteConfirmation()
        
    }
    
    // Used for delete user
    @objc func alertDeleteConfirmation() {
        let alertController = UIAlertController(title: "Are you sure you want to delete?", message: "This will only delete data from What Sticks Databases. Your source data will be unaffected.", preferredStyle: .alert)
        // 'Yes' action
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // Handle the 'Yes' action here
            self?.showSpinner()
            self?.deleteUser()
        }
        // 'No' action
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        // Adding actions to the alert controller
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        // Presenting the alert
        present(alertController, animated: true, completion: nil)
    }
    
    // Used for delete user
    @objc func alertTurnOffLocationTrackingConfirmation() {
        let alertController = UIAlertController(title: "Are you sure?", message: "Turning off location tracking will reduce accuracy.", preferredStyle: .alert)
        // 'Yes' action
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            // Handle the 'Yes' action here
            self?.showSpinner()
            self?.locationFetcher.stopMonitoringLocationChanges()
            
            // Send API permission to track off
            var updateDict = ["location_permission":"False","location_reoccuring_permission":"False"]
            if self!.locationFetcher.userLocationManagerAuthStatus == "Authorized Always" || self!.locationFetcher.userLocationManagerAuthStatus == "Authorized When In Use" ||  self!.locationFetcher.userLocationManagerAuthStatus == "Restricted"{
                updateDict["location_permission"]="True"
            }
            self!.userStore.callUpdateUser(endPoint: .update_user_location_with_lat_lon, updateDict: updateDict) { resultString in
                switch resultString{
                case .success(_):
                    print("-successfully updated")
                    self?.removeSpinner()
                    self?.swtchLocationDayWeather.isOn=false
                    // Set Location Label
                    let initialSwitchStateText = (self?.swtchLocationDayWeather.isOn)! ? "on" : "off"
                    self?.lblLocationDayWeatherSwitch.text = "Track Location (\(initialSwitchStateText)): "
                case .failure(_):
                    print("-failed to update user status")
                    self?.removeSpinner()
                    self?.templateAlert(alertTitle: "Unsuccessful update", alertMessage: "Try again or email nrodrig1@gmail.com.")
                    
                    self?.swtchLocationDayWeather.isOn=true
                    // Set Location Label
                    let initialSwitchStateText = (self?.swtchLocationDayWeather.isOn)! ? "on" : "off"
                    self?.lblLocationDayWeatherSwitch.text = "Track Location (\(initialSwitchStateText)): "
                }
            }
        }
        // 'No' action
        let noAction = UIAlertAction(title: "No", style: .cancel) {[weak self] _ in
            self?.swtchLocationDayWeather.isOn=true
            self?.setLocationSwitchLabelText()
        }
        
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /* Action Methods */
    
    
    func deleteUser(){
        self.userStore.callDeleteUser { responseResult in
            switch responseResult{
            case .success(_):
                print("- ManageUserVC: received success response from WSAPI")
                self.userStore.deleteJsonFile(filename: "user.json")
                self.userStore.deleteJsonFile(filename: "arryDashboardTableObjects.json")
                self.userStore.deleteJsonFile(filename: "arryDataSourceObjects.json")
                self.userStore.arryDataSourceObjects = [DataSourceObject]()
                self.userStore.arryDashboardTableObjects = [DashboardTableObject]()
                self.removeSpinner()
                let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                loginVC.txtEmail.text = ""
                loginVC.txtPassword.text = ""
                
                // Accessing the scene delegate and then the window
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    window.rootViewController = UINavigationController(rootViewController: loginVC)
                }
                
                
            case let .failure(error):
                print("- got an error response for delete_user endpoint")
                self.removeSpinner()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.templateAlert(alertMessage: error.localizedDescription)
                }
            }
        }
    }
    
}



class InfoVC: UIViewController{
    //    var strgTitle
    //    var strgDefinition: String
    var dashboardTableObject: DashboardTableObject?
    var lblTitle = UILabel()
    var lblDetails = UILabel()
    var vwInfo = UIView()
    
    init(dashboardTableObject: DashboardTableObject?){
        //        self.strgDefinition = strgDefinition
        self.dashboardTableObject = dashboardTableObject
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's frame to take up most of the screen except for 5 percent all sides
        self.view.frame = UIScreen.main.bounds.inset(by: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        setupView()
        addTapGestureRecognizer()
    }
    private func setupView(){
        lblTitle.text = self.dashboardTableObject?.dependentVarName
        lblTitle.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblTitle.translatesAutoresizingMaskIntoConstraints=false
        lblDetails.text = self.dashboardTableObject?.definition
        lblDetails.numberOfLines = 0
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.6)
        vwInfo.backgroundColor = UIColor.systemBackground
        vwInfo.layer.cornerRadius = 12
        vwInfo.layer.borderColor = UIColor(named: "gray-500")?.cgColor
        vwInfo.layer.borderWidth = 2
        vwInfo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vwInfo)
        vwInfo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive=true
        vwInfo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        vwInfo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.90).isActive=true
        vwInfo.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 20)).isActive=true
        
        
        vwInfo.addSubview(lblTitle)
        lblTitle.topAnchor.constraint(equalTo: vwInfo.topAnchor, constant: heightFromPct(percent: 2)).isActive=true
        lblTitle.leadingAnchor.constraint(equalTo: vwInfo.leadingAnchor, constant: widthFromPct(percent: 2)).isActive=true
        vwInfo.addSubview(lblDetails)
        lblDetails.translatesAutoresizingMaskIntoConstraints=false
        lblDetails.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: heightFromPct(percent: 2)).isActive=true
        lblDetails.leadingAnchor.constraint(equalTo: vwInfo.leadingAnchor,constant: widthFromPct(percent: 2)).isActive=true
        lblDetails.trailingAnchor.constraint(equalTo: vwInfo.trailingAnchor, constant: widthFromPct(percent: -2)).isActive=true
        //        lblDetails.centerYAnchor.constraint(equalTo: vwInfo.centerYAnchor).isActive=true
    }
    
    private func addTapGestureRecognizer() {
        // Create a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // Add the gesture recognizer to the view
        view.addGestureRecognizer(tapGesture)
    }
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
}
