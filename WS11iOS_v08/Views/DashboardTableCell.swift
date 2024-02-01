//
//  DashboardTableCell.swift
//  WS11iOS_v08
//
//  Created by Nick Rodriguez on 31/01/2024.
//

import UIKit


class DashboardTableCell: UITableViewCell {
    
    // Properties
    var indepVarObject: IndepVarObject!
    var depVarVerb:String!
    var dblCorrelation: Double!
    var lblIndepVarName = UILabel()
    var lblIndVarObservationCount = UILabel()
    var vwCircle = UIView()
    var lblCorrelation = UILabel()
    var lblDefinition = UILabel()
    var lblWhatItMeansToYou = UILabel()
    var txtWhatItMeansToYou = String()
    
    // additional layout paramters
    var isVisible: Bool = false {
        didSet {
            lblCorrelation.isHidden = !isVisible
            stckVwClick.isHidden = !isVisible
            showLblDef()
            layoutIfNeeded()
        }
    }
    var lblDefinitionConstraints: [NSLayoutConstraint] = []
    var stckVwClick = UIStackView()
    //    var unclickedBottomConstraint: [NSLayoutConstraint] = []
    
    // Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Setup views and constraints
    private func setupViews() {
        
        contentView.addSubview(lblIndepVarName)
        lblIndepVarName.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        lblIndepVarName.translatesAutoresizingMaskIntoConstraints = false
        lblIndepVarName.accessibilityIdentifier="lblIndepVarName"
        lblIndepVarName.numberOfLines = 0
        
        contentView.addSubview(vwCircle)
        vwCircle.backgroundColor = .systemBlue
        vwCircle.layer.cornerRadius = heightFromPct(percent: 10) * 0.5 // Adjust as needed
        vwCircle.translatesAutoresizingMaskIntoConstraints = false
        vwCircle.accessibilityIdentifier="vwCircle"
        
        contentView.addSubview(lblCorrelation)
        lblCorrelation.accessibilityIdentifier="lblCorrelation"
        lblCorrelation.isHidden = true
        lblCorrelation.translatesAutoresizingMaskIntoConstraints=false
        lblCorrelation.font = UIFont(name: "ArialRoundedMTBold", size: 20)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            lblIndepVarName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
            lblIndepVarName.centerYAnchor.constraint(equalTo: vwCircle.centerYAnchor),
            lblIndepVarName.trailingAnchor.constraint(equalTo: vwCircle.leadingAnchor, constant: widthFromPct(percent: 1)),
            
            vwCircle.topAnchor.constraint(equalTo: contentView.topAnchor,constant: heightFromPct(percent: 2)),
            vwCircle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -2)),
            vwCircle.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: heightFromPct(percent: -2)),
            vwCircle.heightAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            vwCircle.widthAnchor.constraint(equalToConstant: heightFromPct(percent: 10)),
            
            lblCorrelation.centerXAnchor.constraint(equalTo: vwCircle.centerXAnchor),
            lblCorrelation.centerYAnchor.constraint(equalTo: vwCircle.centerYAnchor),
        ])
        contentView.addSubview(stckVwClick)
        stckVwClick.isHidden = true
        stckVwClick.accessibilityIdentifier = "stckVwClick"
        stckVwClick.axis = .vertical
        stckVwClick.spacing = heightFromPct(percent: 2)
        stckVwClick.translatesAutoresizingMaskIntoConstraints=false
        stckVwClick.addArrangedSubview(lblDefinition)
        stckVwClick.addArrangedSubview(lblWhatItMeansToYou)
        
        //        contentView.addSubview(lblDefinition)
        lblDefinition.accessibilityIdentifier="lblDefinition"
        //        lblDefinition.isHidden = true
        lblDefinition.translatesAutoresizingMaskIntoConstraints = false
        lblDefinition.font = UIFont(name: "ArialRoundedMTBold", size: 15)
        lblDefinition.numberOfLines = 0 // Enable multi-line
        
        //        contentView.addSubview(lblWhatItMeansToYou)
        lblWhatItMeansToYou.accessibilityIdentifier="lblWhatItMeansToYou"
        //        lblWhatItMeansToYou.isHidden = true
        lblWhatItMeansToYou.translatesAutoresizingMaskIntoConstraints = false
        lblWhatItMeansToYou.font = UIFont(name: "ArialRoundedMTBold", size: 15)
        lblWhatItMeansToYou.numberOfLines = 0 // Enable multi-line
        
    }
    
    
    // Additional methods as needed
    func configureCellWithIndepVarObject(){
        lblIndepVarName.text = indepVarObject.independentVarName
        createMultiFontDefinitionString()
        
        
        if let unwp_corr_value = indepVarObject.correlationValue {
            dblCorrelation = Double(unwp_corr_value)
            if dblCorrelation < 0.0{
                vwCircle.backgroundColor = UIColor.wsYellowFromDecimal(CGFloat(dblCorrelation))
            }
            else{
                vwCircle.backgroundColor = UIColor.wsBlueFromDecimal(CGFloat(dblCorrelation))
            }
            lblCorrelation.text = String(format: "%.2f", Double(unwp_corr_value) ?? 0.0)
            whatItMeansToYou()
            //            lblWhatItMeansToYou.text = txtWhatItMeansToYou
        }
    }
    func showLblDef() {
        if lblDefinitionConstraints.isEmpty {
            // Create constraints only once and store them
            lblDefinitionConstraints = [
                stckVwClick.topAnchor.constraint(equalTo: lblIndepVarName.bottomAnchor, constant: heightFromPct(percent: 4)),
                stckVwClick.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: heightFromPct(percent: -1)),
                stckVwClick.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: widthFromPct(percent: 2)),
                stckVwClick.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: widthFromPct(percent: -4)),
            ]
        }
        // Activate or deactivate constraints
        if isVisible {
            //            NSLayoutConstraint.deactivate(unclickedBottomConstraint)
            NSLayoutConstraint.activate(lblDefinitionConstraints)
            
        } else {
            NSLayoutConstraint.deactivate(lblDefinitionConstraints)
            //            NSLayoutConstraint.activate(unclickedBottomConstraint)
        }
    }
    func createMultiFontDefinitionString(){
        let boldUnderlinedText = "Definition:"
        let regularText = " " + (indepVarObject.definition ?? "<try reloading>")
        // Create an attributed string for the bold and underlined part
        let boldUnderlinedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let boldUnderlinedAttributedString = NSMutableAttributedString(string: boldUnderlinedText, attributes: boldUnderlinedAttributes)
        // Create an attributed string for the regular part
        let regularAttributedString = NSAttributedString(string: regularText)
        // Combine them
        boldUnderlinedAttributedString.append(regularAttributedString)
        // Set the attributed text to the label
        lblDefinition.attributedText = boldUnderlinedAttributedString
    }
    
    func whatItMeansToYou(){
        let strCorrelation = String(format: "%.2f", Double(dblCorrelation))
        var detailsText = String()
        if self.dblCorrelation > 0.25 {
            detailsText = "Since your sign here is positive \(strCorrelation) and closer to 1.0, this means as your \(self.indepVarObject.noun ?? "<try reloading screen>") increases you \(self.depVarVerb ?? "<try reloading screen>" ) more."
        }
        else if self.dblCorrelation > -0.25 {
            detailsText = "Since the value is close to 0.0, this means your \(self.indepVarObject.noun ?? "<try reloading screen>") doesn’t have much of an impact on how much you \(self.depVarVerb ?? "<try reloading screen>" )."
        } else {
            detailsText = "Since your sign here is negative \(strCorrelation) and closer to -1.0, this means as your \(self.indepVarObject.noun ?? "<try reloading screen>") increases you \(self.depVarVerb ?? "<try reloading screen>" ) less."
        }
        let boldUnderlinedText = "For you:"
        let regularText = " " + detailsText
        // Create an attributed string for the bold and underlined part
        let boldUnderlinedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 17),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        let boldUnderlinedAttributedString = NSMutableAttributedString(string: boldUnderlinedText, attributes: boldUnderlinedAttributes)
        // Create an attributed string for the regular part
        let regularAttributedString = NSAttributedString(string: regularText)
        // Combine them
        boldUnderlinedAttributedString.append(regularAttributedString)
        // Set the attributed text to the label
        lblWhatItMeansToYou.attributedText = boldUnderlinedAttributedString
    }
}
