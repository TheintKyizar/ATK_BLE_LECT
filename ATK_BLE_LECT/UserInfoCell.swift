//
//  UserInfoCell.swift
//  ATK_BLE_LECT
//
//  Created by Kyaw Lin on 23/10/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class UserInfoCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var value: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(labelText:String,valueText:String,stepperBool:Bool){
        label.text = labelText
        value.text = valueText
        stepper.isHidden = true
        if stepperBool == true{
            stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
            let stepperValue = Int(UserDefaults.standard.string(forKey: "notification time")!)
            stepper.value = Double(stepperValue!)
            stepper.minimumValue = 5
            stepper.maximumValue = 20
            stepper.stepValue = 5
            stepper.isHidden = false
            
        }
    }
    
   @objc func stepperValueChanged(_ sender: UIStepper) {
        
        let stepperValue = Int(sender.value)
        value.text = "before \(stepperValue) mins"
        UserDefaults.standard.set(stepperValue, forKey: "notification time")
        NotificationCenter.default.post(name: Notification.Name(rawValue:"stepper changed"), object: nil)
        
    }
    
}
