//
//  LoginController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        
        removeKeyBoardNotification()
        registerKeyBoardNotification()
        
        if let username = UserDefaults.standard.string(forKey: "username"){
            usernameTxt.text = username
        }
        
        usernameTxt.delegate = self
        passwordTxt.delegate = self
        usernameTxt.returnKeyType = .done
        usernameTxt.returnKeyType = .done
        usernameTxt.addTarget(self, action: #selector(usernameDonePressed), for: .editingDidEnd)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint?.constant = 30
            } else {
                self.keyboardHeightLayoutConstraint?.constant = ((endFrame?.size.height)! + 2 ) 
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    private func removeKeyBoardNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func registerKeyBoardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc private func usernameDonePressed(){
        
    }
    
    
    @IBAction func LoginPressed(_ sender: UIButton) {
        
        if !(usernameTxt.text?.isEmpty)! && !(passwordTxt.text?.isEmpty)!{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if appdelegate.isInternetAvailable() == true {
                self.login()
            }
            else {
                displayAlert(title: "LOGIN FAILED", message: "Your phone has no internet connection!")
            }
            
        }else{
            
            //Text fields empty
             displayAlert(title: "Missing infomations", message: "Both username and password are required")
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
                
                log.info("Successfully logged in")
                UserDefaults.standard.set(self.usernameTxt.text!, forKey: "username")
                UserDefaults.standard.set(self.passwordTxt.text!, forKey: "password")
                
                if let JSON = response.result.value as? [String:AnyObject]{
                    
                    Constant.lecturer_id = JSON["id"] as! Int
                    Constant.name = JSON["name"] as! String
                    Constant.token = JSON["token"] as! String
                    Constant.major = JSON["major"] as! UInt16
                    Constant.minor = JSON["minor"] as! UInt16
                
                    UserDefaults.standard.set(Constant.lecturer_id, forKey: "id")
                    UserDefaults.standard.set(Constant.name, forKey: "name")
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    UserDefaults.standard.set(Constant.major, forKey: "major")
                    UserDefaults.standard.set(Constant.minor, forKey: "minor")
                    
                    if let office = JSON["office"] as? String{
                        UserDefaults.standard.set(office, forKey: "office")
                    }else{
                        UserDefaults.standard.removeObject(forKey: "office")
                    }
                    if let email = JSON["email"] as? String{
                        UserDefaults.standard.set(email, forKey: "email")
                    }else{
                        UserDefaults.standard.removeObject(forKey: "email")
                    }
                    if let phone = JSON["phone"] as? String{
                        UserDefaults.standard.set(phone, forKey: "phone")
                    }else{
                        UserDefaults.standard.removeObject(forKey: "phone")
                    }
                    
                    self.setupData()
                    
                }else{
                    alertController.dismiss(animated: false, completion: nil)
                    //display alert
                }
                
            }else if code == 400{
                alertController.dismiss(animated: false, completion: nil)
                log.info("Login failed")
            }else{
                alertController.dismiss(animated: false, completion: nil)
                log.info("Server busy...")
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
                        newLesson.credit_unit = Int((lesson["credit_unit"] as? String)!)
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
                log.info("Done loading timetable")
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func displayAlert(title:String,message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
    }
}
