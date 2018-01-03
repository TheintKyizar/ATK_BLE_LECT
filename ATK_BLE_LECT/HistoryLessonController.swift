//
//  HistoryLessonController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/6/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class HistoryLessonController: UITableViewController {
    
    var lesson_date:LessonDate?
    var students = [Student]()
    var status = [Status]()
    var count = Int()
    var selectedIndexPath = [IndexPath]()
    var currentTag = Int()
    var internetConnection = Bool()
    
    let spinnerController = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshStudents()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "ManualAttendanceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        spinnerController.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        spinnerController.color = UIColor.black
        self.view.addSubview(spinnerController)
        spinnerController.startAnimating()
        
        refreshControl?.addTarget(self, action: #selector(refreshStudents), for: .valueChanged)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc private func refreshStudents(){
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true{
            internetConnection = true
            Timer.after(1, {
                NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"load table"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.refreshTable), name: Notification.Name(rawValue: "load table"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(self.sessionExpired), name: Notification.Name(rawValue: "session expired"), object: nil)
                alamofire.loadStudentsAndStatus(lesson: GlobalData.timetable.filter({$0.lesson_id! == (self.lesson_date?.lesson_id)!}).first!, lesson_date: self.lesson_date!, returnString: "load table")
            })
        }else{
            //refreshControl?.endRefreshing()
            internetConnection = false
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alert.dismiss(animated: false, completion:nil)
                self.refreshControl?.endRefreshing()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc private func sessionExpired(){
        
        let username = UserDefaults.standard.string(forKey: "username")
        let password = UserDefaults.standard.string(forKey: "password")
        let device_hash = UIDevice.current.identifierForVendor?.uuidString
        
        let parameters:[String:Any] = [
            "username" : username!,
            "password" : password!,
            "device_hash" : device_hash!
        ]
        
        Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            
            let code = response.response?.statusCode
            if code == 200{
                
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
                    self.refreshStudents()
                }
                
            }else{
                
                NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "session expired"), object: nil)
                let alertController = UIAlertController(title: "Session expired", message: "Please log in to continue", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    self.performSegue(withIdentifier: "sign_in_segue", sender: nil)
                })
                alertController.addAction(action)
                self.present(alertController, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
    @objc private func refreshTable(){
        refreshControl?.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "load table"), object: nil)
        self.spinnerController.removeFromSuperview()
        self.spinnerController.stopAnimating()
        students = GlobalData.students
        status = GlobalData.studentStatus
        count  = 0
        if students.count > 0 && status.count > 0{
            for i in 0...students.count-1{
                if let _ = students.filter({$0.student_id! == status[i].student_id!}).first{
                    count += 1
                }
            }
        }
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if internetConnection == false{
            title = "No internet connection"
        }
        return title
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if internetConnection == false{
            guard let header = view as? UITableViewHeaderFooterView else {return}
            header.textLabel?.textColor = UIColor.red
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ManualAttendanceCell
        let mStatus = (status.filter({$0.student_id! == students[indexPath.row].student_id!}).first?.status)!
        cell?.commonInit(studentName: students[indexPath.row].name!, status: mStatus,student_id: students[indexPath.row].student_id!)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        doneButton.tag = indexPath.row
        toolbar.setItems([doneButton], animated: false)
        cell?.view.addSubview(toolbar)
        cell?.selectionStyle = .none
        return cell!
    }
    
    @objc func doneButtonPressed(_ sender:UIButton){
        
        let row = sender.tag
        currentTag = row
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done updating status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(doneUpdatingStatus), name: Notification.Name(rawValue:"done updating status"), object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"cancel updating status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(cancelUpdatingStatus), name: Notification.Name(rawValue:"cancel updating status"), object: nil)
            if cell.selectedValue != "Present"{
                if cell.selectedValue != "Other..."{
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReasonPopUp") as! PopupController
                    popOverVC.lesson_date = self.lesson_date!
                    popOverVC.student_id = students[sender.tag].student_id!
                    popOverVC.status = checkStatus(status: cell.selectedValue)
                    popOverVC.lateBool = false
                    self.present(popOverVC, animated: true, completion: nil)
                }else{
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReasonPopUp") as! PopupController
                    popOverVC.lesson_date = self.lesson_date!
                    popOverVC.student_id = students[sender.tag].student_id!
                    popOverVC.lateBool = true
                    self.present(popOverVC, animated: true, completion: nil)
                }
            }else{
                self.view.addSubview(spinnerController)
                spinnerController.startAnimating()
                alamofire.updateStatus(lesson_date: self.lesson_date!, student_id: students[sender.tag].student_id!, status: checkStatus(status: cell.selectedValue))
            }
        }
    }
    
    @objc func cancelUpdatingStatus(){
        spinnerController.removeFromSuperview()
        spinnerController.stopAnimating()
        let indexPath = IndexPath(row: currentTag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            cell.view.isHidden = true
        }
        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
        }
    }
    
    @objc func doneUpdatingStatus(){
        spinnerController.removeFromSuperview()
        spinnerController.stopAnimating()
        let indexPath = IndexPath(row: currentTag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            cell.view.isHidden = true
            if cell.selectedValue != "Other..."{
                status.filter({$0.student_id! == students[currentTag].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            cell.backgroundColor = UIColor.white
            if selectedIndexPath.filter({$0 == indexPath}).first != nil{
                cell.view.isHidden = true
                selectedIndexPath = selectedIndexPath.filter(){$0 != indexPath}
            }else{
                if selectedIndexPath.count > 0{
                    for i in selectedIndexPath{
                        if let cell2 = tableView.cellForRow(at: i) as? ManualAttendanceCell{
                            cell2.view.isHidden = true
                            selectedIndexPath = selectedIndexPath.filter(){$0 != i}
                        }
                    }
                }
                cell.view.isHidden = false
                selectedIndexPath.append(indexPath)
            }
            UIView.animate(withDuration: 0.3, animations: {
                tableView.beginUpdates()
                tableView.endUpdates()
            })
        }
    }
    
    private func checkStatus(status:String) -> Int{
        switch status {
        case "Absent":
            return -1
        case "Present":
            return 0
        default:
            let split = status.split(separator: " ")
            return Int(split[0])!
        }
    }
    
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
