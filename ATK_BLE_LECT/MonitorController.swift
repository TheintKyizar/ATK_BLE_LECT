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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkLessons()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    private func checkLessons(){
        if checkLesson.checkCurrentLesson() == false{
            if checkLesson.checkNextLesson() == false{
                //No lesson today
                print("No lesson today")
            }else{
                //Display next lesson infos
                print("Next lesson")
                lesson = GlobalData.nextLesson
            }
        }else{
            //current lesson
            print("Current lesson")
            lesson = GlobalData.currentLesson
            alamofire.loadStudents(lesson: lesson!)
            let nlesson = GlobalData.weeklyTimetable.filter({$0.lesson_id! == lesson?.lesson_id!}).first
            let lesson_date = LessonDate()
            lesson_date.lesson_date = nlesson?.ldate
            lesson_date.lesson_date_id = nlesson?.ldateid
            lesson_date.lesson_id = nlesson?.lesson_id
            alamofire.getStudentStatus(lesson: lesson_date)
            NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "done loading status"), object: nil)
        }
    }

    @IBAction func refreshButtonn(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true {
            self.tableView.reloadData()
        }
        else {
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.turnOnData()
                //self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
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
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true {
        self.tableView.reloadData()
        }
        else {
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.turnOnData()
                //self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GlobalData.students.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (lesson?.subject ?? "") + " " + (lesson?.catalog ?? "")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! StudentCell
        cell.studentName.text = GlobalData.students[indexPath.row].name
        if let status = GlobalData.studentStatus.filter({$0.student_id == GlobalData.students[indexPath.row].student_id}).first{
            cell.status.text = checkStatus(status: status)
        }
        return cell
    }
    
    private func checkStatus(status:Status) -> String{
        switch status.status!{
        case -1: return "Not taken"
        case 0: return "Taken"
        default: return "Late"
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
