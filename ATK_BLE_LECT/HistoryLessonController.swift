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
    
    let spinnerController = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done loading students and status"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "done loading students and status"), object: nil)
        alamofire.loadStudentsAndStatus(lesson: GlobalData.timetable.filter({$0.lesson_id! == (lesson_date?.lesson_id)!}).first!, lesson_date: lesson_date!)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "ManualAttendanceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        spinnerController.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        spinnerController.color = UIColor.black
        self.view.addSubview(spinnerController)
        spinnerController.startAnimating()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc private func refreshTable(){
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
        
        self.view.addSubview(spinnerController)
        spinnerController.startAnimating()
        let row = sender.tag
        currentTag = row
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            /*cell.view.isHidden = true
            status.filter({$0.student_id! == students[row].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
            log.info(cell.student_id)*/
            self.view.addSubview(spinnerController)
            spinnerController.startAnimating()
            tableView.allowsSelection = false
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done updating status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(doneUpdatingStatus), name: Notification.Name(rawValue:"done updating status"), object: nil)
            alamofire.updateStatus(lesson_date: self.lesson_date!, student_id: students[sender.tag].student_id!, status: checkStatus(status: cell.selectedValue))
        }
    }
    
    @objc func doneUpdatingStatus(){
        self.spinnerController.removeFromSuperview()
        tableView.allowsSelection = true
        let indexPath = IndexPath(row: currentTag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            cell.view.isHidden = true
            status.filter({$0.student_id! == students[currentTag].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
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
