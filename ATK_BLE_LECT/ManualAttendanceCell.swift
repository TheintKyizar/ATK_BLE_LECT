//
//  ManualAttendanceCell.swift
//  ATK_BLE_LECT
//
//  Created by Kyaw Lin on 26/10/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class ManualAttendanceCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var student: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    @IBOutlet weak var statusTime: UILabel!
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var view: UIView!
    
    var selectedValue:String = "Absent"
    var student_id = Int()
    
    let pickerData = [
        "Absent","Present","5 mins","10 mins","15 mins","20 mins","25 mins","30 mins"
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func commonInit(studentName:String,status:Int,student_id:Int){
        student.text = studentName
        statusIcon.image = checkStatus(status: status)
        if status > 0 {
            statusTime.text = String(describing: status) + " mins"
            statusTime.isHidden = false 
        }else{
            statusTime.isHidden = true
        }
        picker.delegate = self
        picker.dataSource = self
        self.student_id = student_id
    }
    
    @objc func doneButtonPressed(){
        view.isHidden = true
        statusIcon.image = checkStatus(status: selectedValue)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    private func checkStatus(status:String) -> UIImage{
        switch status {
        case "Absent":
            return #imageLiteral(resourceName: "red")
        case "Present":
            return #imageLiteral(resourceName: "green")
        default:
            return #imageLiteral(resourceName: "yellow")
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
