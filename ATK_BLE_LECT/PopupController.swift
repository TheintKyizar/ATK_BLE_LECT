//
//  PopupController.swift
//  ATK_BLE_LECT
//
//  Created by Kyaw Lin on 6/11/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class PopupController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lateLabel: UILabel!
    @IBOutlet weak var lateTextField: UITextField!
    
    var lateBool:Bool?
    var student_id:Int?
    var lesson_date:LessonDate?
    var status:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = ""
        hideKeyboardWhenTappedAround()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        if lateBool == true{
            lateLabel.isHidden = false
            lateTextField.isHidden = false
        }else{
            lateLabel.isHidden = true
            lateTextField.isHidden = true
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "cancel updating status"), object: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        
        if lateTextField.isHidden == false{
            if lateTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
                guard let mStatus = Int(lateTextField.text!) else {
                    let alertController = UIAlertController(title: "Missing information", message: "Please enter the timing for late", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        alertController.dismiss(animated: false, completion: nil)
                    })
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: false, completion: nil)
                    return
                }
                status = mStatus
                
                NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done updating status"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(doneUpdatingStatus), name: Notification.Name(rawValue:"done updating status"), object: nil)
                
                //change mins to seconds
                if status! > 0 {
                    status = status! * 60
                }
                alamofire.updateStatus(lesson_date: self.lesson_date!, student_id: student_id!, status: status!)
            }
            
        }else{
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done updating status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(doneUpdatingStatus), name: Notification.Name(rawValue:"done updating status"), object: nil)
            
            //change mins to seconds
            if status! > 0 {
                status = status! * 60
            }
            alamofire.updateStatus(lesson_date: self.lesson_date!, student_id: student_id!, status: status!)
        }
        
    }
    
    @objc private func doneUpdatingStatus(){
        GlobalData.studentStatus.filter({$0.student_id == self.student_id!}).first?.status = status
        self.dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
