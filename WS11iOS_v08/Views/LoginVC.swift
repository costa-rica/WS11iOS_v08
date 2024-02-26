//
//  ViewController.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import UIKit
import Sentry

class LoginVC: TemplateVC {
    
    var userStore: UserStore!
    var requestStore: RequestStore!
    var appleHealthDataFetcher: AppleHealthDataFetcher!
    var healthDataStore: HealthDataStore!
    var locationFetcher: LocationFetcher!
    
    // Login
    let stckVwLogin = UIStackView()//accessIdentifier set
    let stckVwEmailRow = UIStackView()//accessIdentifier set
    let stckVwPasswordRow = UIStackView()//accessIdentifier set
    let lblEmail = UILabel()
    var txtEmail = PaddedTextField()
    let lblPassword = UILabel()
    var txtPassword = PaddedTextField()
    let btnShowPassword = UIButton()
    var btnLogin=UIButton()
    // Remember me
    var stckVwRememberMe: UIStackView!//accessIdentifier set
    let swRememberMe = UISwitch()
    // Forgot Password
    var signUpLabel:UILabel!
    var btnForgotPassword:UIButton!
    //LoginVC
    let lblScreenNameTitle = UILabel()
    var lblLogout:UILabel!
    // Remember me
    var stckVwDevOrProd: UIStackView!//accessIdentifier set
    let swDevOrProd = UISwitch()
    var lblDevOrProd = UILabel()
    var token = "token" {
        didSet{
            if token != "token"{
                self.setDashboardObject()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestStore = RequestStore()
        self.userStore = UserStore()
        self.userStore.currentDashboardObjPos = 0
        self.userStore.requestStore = self.requestStore
        self.appleHealthDataFetcher = AppleHealthDataFetcher()
        self.healthDataStore = HealthDataStore()
        self.healthDataStore.requestStore = self.requestStore
        self.setupIsDev(urlStore: requestStore.urlStore)
        self.locationFetcher = LocationFetcher()
        self.locationFetcher.requestLocationPermission()
        // Set up tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
        setup_lblTitle()
        setup_stckVwLogin()
        setup_btnLogin()
        setup_stckVwRememberMe()
        setupForgotPasswordButton()
        setupSignUpLabel()
        setup_checkFiles()
        if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
            print("Documents Directory: \(documentsPath)")
        }
//        setup_stckVwDevOrProd()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.isInitialViewController=true
        self.changeLogoForLoginVC()
    }// This is just to set up logo in vwTopBar
    
    func setup_checkFiles(){
        userStore.checkUserJson { responseResult in
            DispatchQueue.main.async {
                switch responseResult{
                case  .success(_):
                    self.txtEmail.text=self.userStore.user.email
                    self.txtPassword.text=self.userStore.user.password
                case .failure(_):
                    print("no user found")
                }
            }
        }
        userStore.checkDashboardJson { result in
//            print("- func setup_checkFiles() ")
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    print("arryDashboardTableObjects.json file found and userStore.arryDashboardTableObjects set with \(self.userStore.arryDashboardTableObjects.count) dash objects")
                case let .failure(error):
                    print("No arryDashboardTableObjects.json file found, error: \(error)")
                }
            }
        }
        userStore.checkDataSourceJson { result in
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    print("arryDataSourceObjects.json file found")
                case let .failure(error):
                    print("No arryDataSourceObjects.json file found, error: \(error)")
                }
            }
        }
    }
    func setup_lblTitle(){
        lblScreenNameTitle.text = "Login"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 45)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        view.addSubview(lblScreenNameTitle)
        lblScreenNameTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)).isActive=true
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
    }
    func setup_stckVwLogin(){
        lblEmail.text = "Email"
        lblPassword.text = "Password"
        
        stckVwLogin.translatesAutoresizingMaskIntoConstraints = false
        stckVwEmailRow.translatesAutoresizingMaskIntoConstraints = false
        stckVwPasswordRow.translatesAutoresizingMaskIntoConstraints = false
        txtEmail.translatesAutoresizingMaskIntoConstraints = false
        txtPassword.translatesAutoresizingMaskIntoConstraints = false
        lblEmail.translatesAutoresizingMaskIntoConstraints = false
        lblPassword.translatesAutoresizingMaskIntoConstraints = false
        
        stckVwLogin.accessibilityIdentifier="stckVwLogin"
        stckVwEmailRow.accessibilityIdentifier="stckVwEmailRow"
        stckVwPasswordRow.accessibilityIdentifier = "stckVwPasswordRow"
        txtEmail.accessibilityIdentifier = "txtEmail"
        txtPassword.accessibilityIdentifier = "txtPassword"
        lblEmail.accessibilityIdentifier = "lblEmail"
        lblPassword.accessibilityIdentifier = "lblPassword"
        
        txtPassword.isSecureTextEntry = true
        btnShowPassword.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btnShowPassword.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        stckVwEmailRow.addArrangedSubview(lblEmail)
        stckVwEmailRow.addArrangedSubview(txtEmail)
        
        stckVwPasswordRow.addArrangedSubview(lblPassword)
        stckVwPasswordRow.addArrangedSubview(txtPassword)
        stckVwPasswordRow.addArrangedSubview(btnShowPassword)
        
        stckVwLogin.addArrangedSubview(stckVwEmailRow)
        stckVwLogin.addArrangedSubview(stckVwPasswordRow)
        
        stckVwLogin.axis = .vertical
        stckVwEmailRow.axis = .horizontal
        stckVwPasswordRow.axis = .horizontal
        
        stckVwLogin.spacing = 5
        stckVwEmailRow.spacing = 2
        stckVwPasswordRow.spacing = 2
        
        // Customize txtEmail
        txtEmail.layer.borderColor = UIColor.systemGray.cgColor // Adjust color as needed
        txtEmail.layer.borderWidth = 1.0 // Adjust border width as needed
        txtEmail.layer.cornerRadius = 5.0 // Adjust corner radius as needed
        txtEmail.backgroundColor = UIColor.systemBackground // Adjust for dark/light mode compatibility
        txtEmail.layer.masksToBounds = true

        // Customize txtPassword
        txtPassword.layer.borderColor = UIColor.systemGray.cgColor // Adjust color as needed
        txtPassword.layer.borderWidth = 1.0 // Adjust border width as needed
        txtPassword.layer.cornerRadius = 5.0 // Adjust corner radius as needed
        txtPassword.backgroundColor = UIColor.systemBackground // Adjust for dark/light mode compatibility
        txtPassword.layer.masksToBounds = true
        
        txtEmail.heightAnchor.constraint(equalToConstant: 35).isActive = true // Adjust height as needed
        txtPassword.heightAnchor.constraint(equalToConstant: 35).isActive = true // Adjust height as needed
        
        view.addSubview(stckVwLogin)
        
        NSLayoutConstraint.activate([
            stckVwLogin.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: widthFromPct(percent: self.bodySidePaddingPercentage)),
            stckVwLogin.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)),
            stckVwLogin.topAnchor.constraint(equalTo: self.vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage)),
            
            lblEmail.widthAnchor.constraint(equalTo: lblPassword.widthAnchor),
        ])
        
        view.layoutIfNeeded()// <-- Realizes size of lblPassword and stckVwLogin
        
        // This code makes the widths of lblPassword and btnShowPassword take lower precedence than txtPassword.
        lblPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        btnShowPassword.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setup_btnLogin(){
        btnLogin.setTitle("Login", for: .normal)
        btnLogin.layer.borderColor = UIColor.systemBlue.cgColor
        btnLogin.layer.borderWidth = 2
        btnLogin.backgroundColor = .systemBlue
        btnLogin.layer.cornerRadius = 10
        btnLogin.translatesAutoresizingMaskIntoConstraints = false
        btnLogin.accessibilityIdentifier="btnLogin"
        view.addSubview(btnLogin)
        
        btnLogin.topAnchor.constraint(equalTo: self.stckVwLogin.bottomAnchor, constant: heightFromPct(percent: 10)).isActive=true
        btnLogin.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
        btnLogin.widthAnchor.constraint(equalToConstant: widthFromPct(percent: 80)).isActive=true
        
        btnLogin.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnLogin.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        guard let unwp_email = txtEmail.text,
              let unwp_password = txtPassword.text else {
            self.templateAlert(alertTitle: "Unsuccessful Login", alertMessage: "Must enter email and password")
            return}

        self.userStore.user.email = unwp_email
        self.userStore.user.password = unwp_password
        
        requestLogin()
    }
    
    func requestLogin(){
        guard let _ = txtEmail.text,
              let unwp_password = txtPassword.text else {
            return}

//        print("requestLogin: \(unwp_email), \(unwp_password)")
        userStore.callLoginUser() { responseResultLogin in
            DispatchQueue.main.async {
            switch responseResultLogin{
            case let .success(loginMessageDict):
                if loginMessageDict["alert_title"] == "Failed" {
                    self.templateAlert(alertTitle: "Unsuccessful Login", alertMessage: "\(loginMessageDict["alert_message"]!)")
                    return
                }
                self.requestStore.token = self.userStore.user.token
                self.userStore.user.password = unwp_password //<-- override passwrod

                // Sentry event info only for production
                if self.requestStore.urlStore.apiBase == .prod{
                    let event = Event(level: .info)
                    event.message = SentryMessage(formatted: "User logged in")
                    if let unwp_username = self.userStore.user.username,
                       let unwp_id = self.userStore.user.id {
                        event.extra = ["username":unwp_username, "user_id": unwp_id]
                        SentrySDK.capture(event: event)
                    }
                }
                
                // Send user_location.json file if exists
                self.locationFetcher.checkUserLocationJson { resultBool in
                    switch resultBool{
                    case true:
                        print("file exists")
                        let dictSendUserLocation = DictSendUserLocation()
                        dictSendUserLocation.timestamp_utc = getCurrentUtcDateString()
                        dictSendUserLocation.user_location = self.locationFetcher.arryHistUserLocation
                        self.userStore.callSendUserLocationJsonData(dictSendUserLocation: dictSendUserLocation) { resultBool_SendLocation in
                            switch resultBool_SendLocation{
                            case true:
                                self.userStore.deleteJsonFile(filename: "user_locations.json")
                                self.setLoginVCToken()
                            case false:
                                self.setLoginVCToken()
                            }
                        }
                    case false:
                        print("file does not exist don't send")
                        self.setLoginVCToken()
                    }
                }
                
            case .failure(_):
                self.templateAlert(alertTitle: "Unsuccessful Login", alertMessage: "Did you register?")
                }
            }
        }
    }
    func setLoginVCToken(){
        if let unwp_token = self.userStore.user.token{
            self.token = unwp_token// <-- last because action follows this assignment via didSet()
        }
    }
    
    func setDashboardObject(){
        userStore.checkDashboardJson { result in
            print("* func setDashboardObject() checking: userStore.checkDashboardJson")
            DispatchQueue.main.async{
                switch result{
                case .success(_):
                    self.goToDashboard()
                case let .failure(error):
                    self.userStore.boolDashObjExists=false
                    print("No arryDashboardTableObjects.json file found, error: \(error)")
                    self.goToDashboard()
                }
            }
        }
    }
    
    func goToDashboard(){
        if swRememberMe.isOn{
            self.userStore.writeObjectToJsonFile(object: self.userStore.user, filename: "user.json")
        } else {
            self.userStore.deleteJsonFile(filename: "user.json")
            self.txtEmail.text = ""
            self.txtPassword.text = ""
        }
        self.userStore.callSendDataSourceObjects { responseResult in
            switch responseResult{
            case .success(_):
                print("- Success: userStore.arryDataSourceObj populated")
                self.performSegue(withIdentifier: "goToDashboardVC", sender: self)
            case let .failure(error):
                self.templateAlert(alertTitle: "Alert", alertMessage: "Login successful, but failed to get user dashboard data. Contact Nick at: nrodrig1@gmail.com. Error: \(error)")
            }
        }
    }
    
    @objc func togglePasswordVisibility() {
        txtPassword.isSecureTextEntry = !txtPassword.isSecureTextEntry
        let imageName = txtPassword.isSecureTextEntry ? "eye.slash" : "eye"
        btnShowPassword.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func setup_stckVwRememberMe() {
        stckVwRememberMe = UIStackView()
        let lblRememberMe = UILabel()
        
        lblRememberMe.text = "Remember Me"
        stckVwRememberMe.spacing = 10
        stckVwRememberMe.addArrangedSubview(lblRememberMe)
        stckVwRememberMe.addArrangedSubview(swRememberMe)
        view.addSubview(stckVwRememberMe)
        
        stckVwRememberMe.translatesAutoresizingMaskIntoConstraints = false
        lblRememberMe.translatesAutoresizingMaskIntoConstraints = false
        swRememberMe.translatesAutoresizingMaskIntoConstraints = false
        stckVwRememberMe.accessibilityIdentifier = "stckVwRememberMe"
        lblRememberMe.accessibilityIdentifier = "lblRememberMe"
        swRememberMe.accessibilityIdentifier = "swRememberMe"
        
        stckVwRememberMe.topAnchor.constraint(equalTo: stckVwLogin.bottomAnchor, constant: heightFromPct(percent: 2)).isActive=true
        stckVwRememberMe.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
        stckVwRememberMe.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)).isActive=true
        
        swRememberMe.isOn = true
        self.userStore.rememberMe = true
        
    }
    private func setupForgotPasswordButton() {
        btnForgotPassword = UIButton(type: .system)
        btnForgotPassword.setTitle("Forgot Password?", for: .normal)
        btnForgotPassword.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)

        // Layout the button as needed
        btnForgotPassword.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(btnForgotPassword)
        btnForgotPassword.topAnchor.constraint(equalTo: btnLogin.bottomAnchor, constant: heightFromPct(percent: 5)).isActive=true
        btnForgotPassword.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive=true
    }
    
    @objc private func forgotPasswordTapped() {
        performSegue(withIdentifier: "goToForgotPasswordVC", sender: self)
        print("go to website for forgot password")
//        guard let url = URL(string: "https://what-sticks.com/reset_password") else { return }
//        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    private func setupSignUpLabel() {
        let fullText = "Don’t have an account? Sign up"
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: "Sign up")
        
        // Add underlining or color to 'Sign up'
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        signUpLabel = UILabel()
        view.addSubview(signUpLabel)
        signUpLabel.translatesAutoresizingMaskIntoConstraints=false
        signUpLabel.accessibilityIdentifier="signUpLabel"
        signUpLabel.attributedText = attributedString
        signUpLabel.isUserInteractionEnabled = true
        signUpLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpTapped)))
        
        signUpLabel.topAnchor.constraint(equalTo: vwFooter.topAnchor, constant: heightFromPct(percent: 1)).isActive=true
        signUpLabel.centerXAnchor.constraint(equalTo: vwFooter.centerXAnchor).isActive=true
    }
    @objc func viewTapped() {
        // Dismiss the keyboard
        view.endEditing(true)
    }
    @objc func signUpTapped() {
        performSegue(withIdentifier: "goToRegisterVC", sender: self)
    }
    
    
    func setup_stckVwDevOrProd() {
        stckVwDevOrProd = UIStackView()
        
        lblDevOrProd.text = "Production Server"
        stckVwDevOrProd.spacing = 10
        stckVwDevOrProd.addArrangedSubview(lblDevOrProd)
        stckVwDevOrProd.addArrangedSubview(swDevOrProd)
        view.addSubview(stckVwDevOrProd)
        
        stckVwDevOrProd.translatesAutoresizingMaskIntoConstraints = false
        lblDevOrProd.translatesAutoresizingMaskIntoConstraints = false
        swDevOrProd.translatesAutoresizingMaskIntoConstraints = false
        stckVwDevOrProd.accessibilityIdentifier = "stckVwDevOrProd"
        lblDevOrProd.accessibilityIdentifier = "lblDevOrProd"
        swDevOrProd.accessibilityIdentifier = "swRememberMe"
        swDevOrProd.addTarget(self, action: #selector(switchChanged_swDevOrProd(_:)), for: .valueChanged)
        
        stckVwDevOrProd.bottomAnchor.constraint(equalTo: self.vwFooter.topAnchor, constant: heightFromPct(percent: -2)).isActive=true
        stckVwDevOrProd.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)).isActive=true
        stckVwDevOrProd.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -bodySidePaddingPercentage)).isActive=true
        
        swDevOrProd.isOn = true
        self.requestStore.urlStore.apiBase = APIBase.prod
    }
    @objc func switchChanged_swDevOrProd(_ sender: UISwitch) {
        DispatchQueue.main.async {
            if sender.isOn {
                self.requestStore.urlStore.apiBase = APIBase.prod
                self.setupIsDev(urlStore:self.requestStore.urlStore)
                self.lblDevOrProd.text = "Production Server"
            } else {
                self.requestStore.urlStore.apiBase = APIBase.dev
                self.setupIsDev(urlStore:self.requestStore.urlStore)
                self.lblDevOrProd.text = "Development Server"
            }
        }
    }
    
    
//    /* Location Method*/
//    func getLocationPermission(){
//        locationFetcher.requestLocationPermission()
//        }
    
//    func updateUserLocation(){
//        
//        userStore.callUpdateUser(updateDict: updateDict) { responseResult in
//            switch responseResult{
//            case .success(_):
//                self.removeSpinner()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.templateAlert(alertTitle: "Success!", alertMessage: "location status updated")
//                }
//            case let .failure(error):
//                self.removeSpinner()
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                    self.templateAlert(alertTitle: "Problem sending", alertMessage: "Error: \(error)")
//                }
//            }
//        }
//    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToRegisterVC"){
            let registerVC = segue.destination as! RegisterVC
            registerVC.userStore = self.userStore
            registerVC.requestStore = self.requestStore
            registerVC.locationFetcher = self.locationFetcher
        }
        else if (segue.identifier == "goToDashboardVC"){
            let dashboardVC = segue.destination as! DashboardVC
            dashboardVC.userStore = self.userStore
            dashboardVC.requestStore = self.requestStore
            dashboardVC.appleHealthDataFetcher = self.appleHealthDataFetcher
            dashboardVC.healthDataStore = self.healthDataStore
            dashboardVC.locationFetcher = self.locationFetcher
            self.token = "token"// reset login
        }
        if (segue.identifier == "goToForgotPasswordVC"){
            let forgotPasswordVC = segue.destination as! ForgotPasswordVC
            forgotPasswordVC.userStore = self.userStore
            forgotPasswordVC.requestStore = self.requestStore
//            dashboardVC.appleHealthDataFetcher = self.appleHealthDataFetcher
//            dashboardVC.healthDataStore = self.healthDataStore
//            self.token = "token"// reset login
        }
    }
    
}

