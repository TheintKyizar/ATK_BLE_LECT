//
//  MoreController.swift
//  ATK_BLE_LECT
//
//  Created by Kyaw Lin on 3/11/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class MoreController: UITableViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var office: UILabel!
    @IBOutlet weak var notification: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
    
    private func setup(){
        let stepperValue = UserDefaults.standard.string(forKey: "notification time")
        notification.text = stepperValue! + " mins"
        stepper.value = Double(stepperValue!)!
        stepper.minimumValue = 5
        stepper.maximumValue = 20
        stepper.stepValue = 5
        if let name = UserDefaults.standard.string(forKey: "username"){
            self.name.text = name
        }else{
            self.name.text = "Not set"
        }
        if let email = UserDefaults.standard.string(forKey: "email"){
            self.email.text = email
        }else{
            self.email.text = "Not set"
        }
        if let phone = UserDefaults.standard.string(forKey: "phone"){
            self.phone.text = phone
        }else{
            self.phone.text = "Not set"
        }
        if let office = UserDefaults.standard.string(forKey: "office"){
            self.office.text = office
        }else{
            self.office.text = "Not set"
        }
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        let stepperValue = Int(sender.value)
        notification.text = "\(stepperValue) mins"
        UserDefaults.standard.set(stepperValue, forKey: "notification time")
        NotificationCenter.default.post(name: Notification.Name(rawValue:"stepper changed"), object: nil)
    }
    
    @IBAction func changePasswordPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func signOutPressed(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "id")
        self.performSegue(withIdentifier: "login_segue", sender: nil)
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
