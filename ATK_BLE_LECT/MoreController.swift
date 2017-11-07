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
    @IBOutlet weak var mView: UIView!
    
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.textColor = UIColor.darkGray
        header.backgroundView?.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        header.textLabel?.font = UIFont.systemFont(ofSize: 15)
        // header.backgroundColor = UIColor.white
        
        let borderTop = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 0.5))
        borderTop.backgroundColor = UIColor.lightGray
        
        let borderBottom = UIView(frame: CGRect(x: 0, y: header.bounds.height, width: tableView.bounds.size.width, height: 0.5))
        borderBottom.backgroundColor = UIColor.lightGray
        header.addSubview(borderBottom)
        
        if section > 0 {
            header.addSubview(borderTop)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == 1{
            cell.separatorInset = UIEdgeInsets.zero
        }
        
    }
    
    private func setup(){
        self.tableView.sectionHeaderHeight = 40
        self.tableView.allowsSelection = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        mView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        let stepperValue = UserDefaults.standard.string(forKey: "notification time")
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        notification.text = stepperValue! + " mins"
        stepper.value = Double(stepperValue!)!
        stepper.minimumValue = 5
        stepper.maximumValue = 20
        stepper.stepValue = 5
        
        if let username = UserDefaults.standard.string(forKey: "username"){
            self.name.text = username
        }else{
            self.name.text = "Not set"
        }
        if UserDefaults.standard.string(forKey: "email") != nil{
            self.email.text = UserDefaults.standard.string(forKey: "email")
        }else{
            self.email.text = "Not set"
        }
        if UserDefaults.standard.string(forKey: "phone") != nil{
            self.phone.text = UserDefaults.standard.string(forKey: "phone")
        }else{
            self.phone.text = "Not set"
        }
        if UserDefaults.standard.string(forKey: "office") != nil{
            self.office.text = UserDefaults.standard.string(forKey: "office")
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
