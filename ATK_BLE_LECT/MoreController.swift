//
//  MoreController.swift
//  ATK_BLE_LECT
//
//  Created by Kyi Zar Theint on 8/31/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class MoreController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var email_label: UILabel!
    @IBOutlet weak var phone_label: UILabel!
    @IBOutlet weak var office_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLabels()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupLabels(){
        
        if let name = UserDefaults.standard.string(forKey: "name"){
            name_label.text = name
        }
        if let email = UserDefaults.standard.string(forKey: "email"){
            email_label.text = email
        }
        if let phone = UserDefaults.standard.string(forKey: "phone"){
            phone_label.text = phone
        }
        if let office = UserDefaults.standard.string(forKey: "office"){
            office_label.text = office
        }
        
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        
        UserDefaults.standard.removeObject(forKey: "name")
        self.performSegue(withIdentifier: "login_segue", sender: nil)
        
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
