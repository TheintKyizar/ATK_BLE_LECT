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
    var timer:Timer?
    var lastStatus:[Status]?
    
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
        refreshControl?.addTarget(self, action: #selector(refreshStudents), for: .valueChanged)
    }
    
    @objc private func refreshStudents() {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true {
            Timer.after(1, {
                self.checkLessons()
            })
        }else {
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alert.dismiss(animated: false, completion: nil)
                self.refreshControl?.endRefreshing()
            }))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    private func checkLessons(){
        if checkLesson.checkCurrentLesson() == false{
            if checkLesson.checkNextLesson() == false{
                //No lesson today
                log.info("No lesson today")
                self.title = "No lesson today"
            }else{
                //Display next lesson infos
                log.info("Next lesson")
                self.title = "Next Lesson"
                lesson = GlobalData.nextLesson
            }
        }else{
            //current lesson
            log.info("Currently have lesson")
            lesson = GlobalData.currentLesson
            self.title = (lesson?.subject)! + " " + (lesson?.catalog)!
            let nlesson = GlobalData.weeklyTimetable.filter({$0.lesson_id! == lesson?.lesson_id!}).first
            let mlesson_date = LessonDate()
            mlesson_date.lesson_date = nlesson?.ldate
            mlesson_date.lesson_date_id = nlesson?.ldateid
            mlesson_date.lesson_id = nlesson?.lesson_id
            self.lesson_date = mlesson_date
            
            alamofire.loadStudentsAndStatus(lesson: lesson!, lesson_date: mlesson_date, returnString: "checkLesson")
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "checkLesson"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "checkLesson"), object: nil)
        }
    }
    
    @IBAction func refreshButtonn(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true {
            self.tableView.reloadData()
        }
        else {
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    private func turnOnData() {
        let url = URL(string: "App-Prefs:root=WIFI") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshTable(){
        refreshControl?.endRefreshing()
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "checkLesson"), object: nil)
        self.students = GlobalData.students
        UIView.transition(with: self.tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        self.tableView.reloadData()
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
                    //popOverVC.view.alpha = 0.8
                    popOverVC.lesson_date = self.lesson_date!
                    popOverVC.student_id = students[sender.tag].student_id!
                    popOverVC.status = checkStatus(status: cell.selectedValue)
                    popOverVC.lateBool = false
                    self.present(popOverVC, animated: true, completion: nil)
                }else{
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReasonPopUp") as! PopupController
                    //popOverVC.view.alpha = 0.8
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
    
    override func viewWillAppear(_ animated: Bool) {
        self.startRefreshing()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.stopRefreshing()
    }
    
    @objc func refreshTableLoop(){
        for i in 0...GlobalData.studentStatus.count-1{
            if lastStatus?.filter({$0.student_id == GlobalData.studentStatus[i].student_id}).first?.status != GlobalData.studentStatus[i].status{
                let indexPath = IndexPath(row: i, section: 0)
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        lastStatus = GlobalData.studentStatus
    }
    
    private func startRefreshing(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "refreshLoop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableLoop), name: Notification.Name(rawValue: "refreshLoop"), object: nil)
        if timer == nil{
            timer = Timer.every(3, {
                //refresh status here
                self.lastStatus = GlobalData.studentStatus
                alamofire.loadStudentsAndStatus(lesson: self.lesson!, lesson_date: self.lesson_date!, returnString: "refreshLoop")
            })
        }
    }
    
    private func stopRefreshing(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "refreshLoop"), object: nil)
        if timer != nil{
            timer?.invalidate()
            timer = nil
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
                GlobalData.studentStatus.filter({$0.student_id! == students[currentTag].student_id!}).first?.status = checkStatus(status: cell.selectedValue)
            }
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
