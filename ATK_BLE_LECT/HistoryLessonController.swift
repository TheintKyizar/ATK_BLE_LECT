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

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "refreshStatus"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc private func refreshTable(){
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setup(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters_status:[String:Any] = [
            "lesson_date_id" : (lesson_date?.lesson_date_id)!
        ]
        let parameters_students:[String:Any] = [
            "lesson_id" : (lesson_date?.lesson_id)!
        ]
        
        Alamofire.request(Constant.URLGetStudentOfLesson, method: .post, parameters: parameters_students, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                self.students.removeAll()
                for json in JSON{
                    let newStudent = Student()
                    newStudent.student_id = json["id"] as? Int
                    newStudent.name = json["name"] as? String
                    self.students.append(newStudent)
                }
            }
            Alamofire.request(Constant.URLAtkStatus, method: .post, parameters: parameters_status, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                if let JSON = response.result.value as? [AnyObject]{
                    self.status.removeAll()
                    for json in JSON{
                        let newStatus = Status()
                        newStatus.recorded_time = json["recorded_time"] as? String
                        newStatus.status = json["status"] as? Int
                        newStatus.student_id = json["student_id"] as? Int
                        self.status.append(newStatus)
                    }
                }
                print("Done loading status")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshStatus"), object: nil)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? StudentCell
        let mStatus = (status.filter({$0.student_id! == students[indexPath.row].student_id!}).first?.status)!
        cell?.studentName.text = students[indexPath.row].name
        cell?.status.text = String(mStatus)
        return cell!
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
