//
//  MoreController.swift
//  ATK_BLE_LECT
//
//  Created by Kyi Zar Theint on 8/31/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class MoreController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    var label = ["Name:","Email:","Phone:","Office:","Notification:"]
    var value = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupLabels()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "UserInfoCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupLabels(){
        
        if let name = UserDefaults.standard.string(forKey: "name"){
            value.append(name)
        }
        if let email = UserDefaults.standard.string(forKey: "email"){
            value.append(email)
        }
        if let phone = UserDefaults.standard.string(forKey: "phone"){
            value.append(phone)
        }
        if let office = UserDefaults.standard.string(forKey: "office"){
            value.append(office)
        }
        if let notificationTime = UserDefaults.standard.string(forKey: "notification time"){
            value.append("before \(notificationTime) mins")
        }
        
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        
        UserDefaults.standard.removeObject(forKey: "name")
        self.performSegue(withIdentifier: "login_segue", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserInfoCell
        if indexPath.row != 4{
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], stepperBool: false)
        }else{
            cell.commonInit(labelText: label[indexPath.row], valueText: value[indexPath.row], stepperBool: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return label.count
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
