//
//  MonitorController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/5/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class MonitorController: UITableViewController {

    
    var lesson:Lesson?
    var lesson_date:LessonDate?
    var currentTag = Int()
    var selectedIndexPath = [IndexPath]()
    let spinnerController = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerController.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        spinnerController.color = UIColor.black
        
        students.removeAll()
        self.checkLessons()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib = UINib(nibName: "ManualAttendanceCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIBarButtonItem) {
        self.checkLessons()
        students.removeAll()
        self.tableView.reloadData()
    }
    
    private func checkLessons(){
        if checkLesson.checkCurrentLesson() == false{
            if checkLesson.checkNextLesson() == false{
                //No lesson today
                print("No lesson today")
                self.title = "No lesson today"
            }else{
                //Display next lesson infos
                print("Next lesson")
                self.title = "Next Lesson"
                lesson = GlobalData.nextLesson
            }
        }else{
            //current lesson
            print("Current lesson")
            lesson = GlobalData.currentLesson
            self.title = (lesson?.subject)! + " " + (lesson?.catalog)!
            let nlesson = GlobalData.weeklyTimetable.filter({$0.lesson_id! == lesson?.lesson_id!}).first
            let mlesson_date = LessonDate()
            mlesson_date.lesson_date = nlesson?.ldate
            mlesson_date.lesson_date_id = nlesson?.ldateid
            mlesson_date.lesson_id = nlesson?.lesson_id
            self.lesson_date = mlesson_date
            
            self.view.addSubview(spinnerController)
            spinnerController.startAnimating()
            
            alamofire.loadStudentsAndStatus(lesson: lesson!, lesson_date: mlesson_date)
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "done loading students and status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "done loading students and status"), object: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshTable(){
        self.spinnerController.removeFromSuperview()
        self.spinnerController.stopAnimating()
        self.students = GlobalData.students
        UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ManualAttendanceCell
        cell.commonInit(studentName: students[indexPath.row].name!, status: (GlobalData.studentStatus.filter({$0.student_id == students[indexPath.row].student_id}).first?.status)!, student_id: students[indexPath.row].student_id!)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed(_:)))
        doneButton.tag = indexPath.row
        toolbar.setItems([doneButton], animated: false)
        cell.view.addSubview(toolbar)
        cell.selectionStyle = .none
        return cell
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
    
    @objc func doneButtonPressed(_ sender:UIButton){
        self.view.addSubview(spinnerController)
        spinnerController.startAnimating()
        let row = sender.tag
        currentTag = row
        let indexPath = IndexPath(row: sender.tag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            /*cell.view.isHidden = true
             status.filter({$0.student_id! == students[row].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
             print(cell.student_id)*/
            self.view.addSubview(spinnerController)
            spinnerController.startAnimating()
            tableView.allowsSelection = false
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done updating status"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(doneUpdatingStatus), name: Notification.Name(rawValue:"done updating status"), object: nil)
            alamofire.updateStatus(lesson_date: self.lesson_date!, student_id: GlobalData.students[sender.tag].student_id!, status: checkStatus(status: cell.selectedValue))
        }
    }
    
    @objc func doneUpdatingStatus(){
        self.spinnerController.removeFromSuperview()
        self.spinnerController.stopAnimating()
        tableView.allowsSelection = true
        let indexPath = IndexPath(row: currentTag, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ManualAttendanceCell{
            cell.view.isHidden = true
            GlobalData.studentStatus.filter({$0.student_id! == GlobalData.students[currentTag].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
        }
        UIView.animate(withDuration: 0.3) {
            self.tableView.reloadData()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
