//
//  StudentCell.swift
//  ATK_BLE_LECT
//
//  Created by Kyaw Lin on 24/10/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class StudentCell: UITableViewCell {

    @IBOutlet weak var student: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(studentName:String,status:Int){
        student.text = studentName
        statusIcon.image = checkStatus(status: status)
    }
    
    func commonInit(studentName:String,status:Bool){
        student.text = studentName
        if status == false{
            statusIcon.isHidden = true
        }else{
            statusIcon.isHidden = false
        }
    }
    
    private func checkStatus(status:Int) -> UIImage{
        switch status{
        case -1: return #imageLiteral(resourceName: "red")
        case 0: return #imageLiteral(resourceName: "green")
        default: return #imageLiteral(resourceName: "yellow")
        }
    }
    
}
