//
//  ForgotPasswordVC.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import UIKit

class ForgotPasswordVC: TemplateVC {
    var userStore: UserStore!
    var requestStore: RequestStore!
    let lblScreenNameTitle = UILabel()
    let lblEmail = UILabel()
    var txtEmail = PaddedTextField()
    let btnSubmit = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup_lblTitle()
        setup_VC()
    }
    
    func setup_lblTitle(){
        lblScreenNameTitle.text = "Forgot Password"
        lblScreenNameTitle.font = UIFont(name: "ArialRoundedMTBold", size: 35)
        lblScreenNameTitle.translatesAutoresizingMaskIntoConstraints = false
        lblScreenNameTitle.accessibilityIdentifier="lblScreenNameTitle"
        view.addSubview(lblScreenNameTitle)
        NSLayoutConstraint.activate([
        lblScreenNameTitle.topAnchor.constraint(equalTo: vwTopBar.bottomAnchor, constant: heightFromPct(percent: bodyTopPaddingPercentage/4)),
        lblScreenNameTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: bodySidePaddingPercentage)),
        ])
    }
    func setup_VC(){
        

        lblEmail.accessibilityIdentifier="lblEmail"
        lblEmail.translatesAutoresizingMaskIntoConstraints=false
        lblEmail.text = "Email:"
        view.addSubview(lblEmail)
        
        txtEmail.accessibilityIdentifier="txtEmail"
        txtEmail.translatesAutoresizingMaskIntoConstraints=false
        txtEmail.layer.borderColor = UIColor.systemGray.cgColor // Adjust color as needed
        txtEmail.layer.borderWidth = 1.0 // Adjust border width as needed
        txtEmail.layer.cornerRadius = 5.0 // Adjust corner radius as needed
        txtEmail.backgroundColor = UIColor.systemBackground // Adjust for dark/light mode compatibility
        txtEmail.layer.masksToBounds = true
        view.addSubview(txtEmail)
        
        btnSubmit.accessibilityIdentifier="btnSubmit"
        btnSubmit.translatesAutoresizingMaskIntoConstraints=false
        btnSubmit.setTitle(" Submit ", for: .normal)
        btnSubmit.layer.borderColor = UIColor.systemBlue.cgColor
        btnSubmit.layer.borderWidth = 2
        btnSubmit.backgroundColor = .systemBlue
        btnSubmit.layer.cornerRadius = 10
        btnSubmit.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        btnSubmit.addTarget(self, action: #selector(touchUpInside(_:)), for: .touchUpInside)
        view.addSubview(btnSubmit)
        
        
        NSLayoutConstraint.activate([
            lblEmail.topAnchor.constraint(equalTo: lblScreenNameTitle.bottomAnchor, constant: heightFromPct(percent: 2)),
            lblEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)),
            
            txtEmail.topAnchor.constraint(equalTo: lblEmail.bottomAnchor, constant: heightFromPct(percent: 2)),
            txtEmail.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: widthFromPct(percent: 2)),
            txtEmail.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: widthFromPct(percent: -2)),
            txtEmail.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 5)),
            
            btnSubmit.topAnchor.constraint(equalTo: txtEmail.bottomAnchor, constant: heightFromPct(percent: 4)),
            btnSubmit.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        view.layoutIfNeeded()// <-- Realizes size of lblPassword and stckVwLogin
    }
    
    @objc func touchUpInside(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseInOut], animations: {
            sender.transform = .identity
        }, completion: nil)
        print("pressed submit")
        print(txtEmail.text)
    }
    
    
}
