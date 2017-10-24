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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(labelText:String,valueText:String){
        label.text = labelText
        value.text = valueText
    }
    
}
