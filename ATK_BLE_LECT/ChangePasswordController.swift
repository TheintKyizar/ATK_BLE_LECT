//
//  ChangePasswordController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/7/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class ChangePasswordController: UIViewController{

    @IBOutlet weak var oldTF: UITextField!
    @IBOutlet weak var newTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var trackPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        trackPasswordLabel.isHidden = true
        setupTextFields()
        // Do any additional setup after loading the view.
    }
    
    private func setupTextFields(){
        
        oldTF.returnKeyType = .done
        newTF.returnKeyType = .done
        confirmTF.returnKeyType = .done
        
        oldTF.addTarget(self, action: #selector(oldTFDonePressed), for: .editingDidEnd)
        newTF.addTarget(self, action: #selector(newTFDonePressed), for: .editingDidEnd)
        
    }
    
    @objc private func oldTFDonePressed(){
        newTF.becomeFirstResponder()
    }
    
    @objc private func newTFDonePressed(){
        confirmTF.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func confirmPressed(_ sender: UIButton) {
        
        if oldTF.text == "" || newTF.text == "" || confirmTF.text == ""{
            let alertController = UIAlertController(title: "Missing infomations", message: "Please enter all the fields", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alertController.dismiss(animated: false, completion: nil)
            })
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
        }else{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if appdelegate.isInternetAvailable() == true{
                self.changePassword()
            }else{
                let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    alert.dismiss(animated: false, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    private func changePassword(){
        let token = UserDefaults.standard.string(forKey: "token")!
        if newTF.text! == confirmTF.text!{
            let parameters:[String:Any] = [
                "oldPassword" : oldTF.text!,
                "newPassword" : newTF.text!
            ]
            let headers:HTTPHeaders = [
                "Content-Type" : "application/json",
                "Authorization" : "Bearer " + token
            ]
            let alertController = UIAlertController(title: "Changing Password", message: "Please wait...\n\n", preferredStyle: .alert)
            let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            spinnerIndicator.center = CGPoint(x: 135.0, y: 80.0)
            spinnerIndicator.color = UIColor.black
            spinnerIndicator.startAnimating()
            alertController.view.addSubview(spinnerIndicator)
            self.present(alertController, animated: false, completion: nil)
            Alamofire.request(Constant.URLchangepass, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON(completionHandler: { (response:DataResponse) in
                
                guard let code = response.response?.statusCode else {return}
                log.info("Change Password Status Code: \(code)")
                alertController.dismiss(animated: false, completion: nil)
                switch code{
                case 200:
                    self.performSegue(withIdentifier: "change_password_segue", sender: nil)
                default:
                    let alert = UIAlertController(title: "Error", message: "Password not correct", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                        alert.dismiss(animated: false, completion: nil)
                    }))
                    self.present(alert, animated: false, completion: nil)
                }
            })
        }
    }
    
    @IBAction func confirmPasswordChanged(_ sender: UITextField) {
        if sender.text != newTF.text{
            trackPasswordLabel.textColor = UIColor.red
            trackPasswordLabel.text = "Not matched"
            trackPasswordLabel.isHidden = false
        }else{
            trackPasswordLabel.isHidden = true
        }
    }
    
    @IBAction func currentPassEnterPressed(_ sender: UITextField) {
        newTF.becomeFirstResponder()
    }
    
    @IBAction func newPassEnterPressed(_ sender: UITextField) {
        confirmTF.becomeFirstResponder()
    }
    
    @IBAction func confirmPassEnterPressed(_ sender: UITextField) {
        if oldTF.text == "" || newTF.text == "" || confirmTF.text == ""{
        }else{
            self.changePassword()
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

}
