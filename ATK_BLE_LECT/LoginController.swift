//
//  LoginController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func LoginPressed(_ sender: UIButton) {
        
        if !(usernameTxt.text?.isEmpty)! && !(passwordTxt.text?.isEmpty)!{
            
            //Login
            self.login()
            
        }else{
            
            //Text fields empty
            
        }
        
    }
    
    private func login(){
        
        let username = usernameTxt.text!
        let password = passwordTxt.text!
        let device_hash = UIDevice.current.identifierForVendor?.uuidString
        
        let parameters:[String: Any] = [
            "username" : username,
            "password" : password,
            "device_hash" : device_hash!
        ]
        
        let alertController = UIAlertController(title: "Logging in ", message: "Please wait...\n\n", preferredStyle: .alert)
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
        
        Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            
            let code = response.response?.statusCode
            if code == 200{
                
                print("Successfully logged in")
                UserDefaults.standard.set(self.usernameTxt.text!, forKey: "username")
                UserDefaults.standard.set(self.passwordTxt.text!, forKey: "password")
                
                if let JSON = response.result.value as? [String:AnyObject]{
                    
                    Constant.name = JSON["name"] as! String
                    Constant.token = JSON["token"] as! String
                    Constant.major = JSON["major"] as! UInt16
                    Constant.minor = JSON["minor"] as! UInt16
                
                    UserDefaults.standard.set(Constant.name, forKey: "name")
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    UserDefaults.standard.set(Constant.major, forKey: "major")
                    UserDefaults.standard.set(Constant.minor, forKey: "minor")
                    self.setupData()
                    
                }else{
                    alertController.dismiss(animated: false, completion: nil)
                    //display alert
                }
                
            }else if code == 400{
                alertController.dismiss(animated: false, completion: nil)
                print("Login failed")
            }else{
                alertController.dismiss(animated: false, completion: nil)
                print("Server busy...")
            }
            
        }
        
    }
    
    private func setupData(){
        
        let token = UserDefaults.standard.string(forKey: "token")!
        //load all lessons
        let headersLesson:HTTPHeaders = [
            "Authorization" : "Bearer " + token
        ]
        Alamofire.request(Constant.URLLessonList, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headersLesson).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                
                GlobalData.timetable.removeAll()
                for json in JSON{
                    
                    let newLesson = Lesson()
                    if let lesson = json["lesson"] as? [String:Any]{
                        newLesson.lesson_id = lesson["id"] as? Int
                        newLesson.catalog = lesson["catalog_number"] as? String
                        newLesson.module_id = lesson["module_id"] as? String
                        newLesson.subject = lesson["subject_area"] as? String
                        newLesson.class_section = lesson["class_section"] as? String
                        newLesson.weekday = lesson["weekday"] as? String
                        newLesson.start_time = lesson["start_time"] as? String
                        newLesson.end_time = lesson["end_time"] as? String
                        newLesson.location = lesson["facility"] as? String
                    }
                    
                    if let lesson_date = json["lesson_date"] as? [String:Any]{
                        
                        newLesson.ldateid = lesson_date["id"] as? Int
                        newLesson.ldate = lesson_date["ldate"] as? String
                        
                    }
                    
                    if let venue = json["venue"] as? [String:Any]{
                        
                        newLesson.major = venue["major"] as? UInt16
                        newLesson.minor = venue["minor"] as? UInt16
                        newLesson.venueName = venue["name"] as? String
                        newLesson.location = venue["location"] as? String
                        
                    }
                    GlobalData.timetable.append(newLesson)
                }
                NSKeyedArchiver.archiveRootObject(GlobalData.timetable, toFile: filePath.timetablePath)
                print("Done loading timetable")
                alamofire.loadWeeklyTimetable()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"refreshTable"), object: nil)
                self.dismiss(animated: false, completion: nil)
                self.performSegue(withIdentifier: "tab_bar_segue", sender: nil)
            }
        }
    }
    

}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
