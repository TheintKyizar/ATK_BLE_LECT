//
//  TimetableController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit

class TimetableController: UITableViewController {
    
    let today = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let title = format.formateDate(format: "MMM dd (E)", date: today)
        navigationItem.title = "Timetable \(title)"
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"refreshTable"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue:"refreshTable"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    @objc private func refreshTable(){
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    @IBAction func refreshButton(_ sender: Any) {
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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return GlobalData.weeklyTimetable.filter({$0.weekday == GlobalData.wdayInt[section]}).count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return GlobalData.wdayStr[section]
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! TimetableCell
        let lessonInDay = GlobalData.weeklyTimetable.filter({$0.weekday == GlobalData.wdayInt[indexPath.section]})
        
        let lesson = lessonInDay[indexPath.row]
        cell.lesson = lesson
        

       

        return cell
    }
    private func turnOnData() {
        let url = URL(string: "App-Prefs:root=WIFI") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? TimetableCell else{return}
        
        self.performSegue(withIdentifier: "lesson_detail_segue", sender: cell.lesson)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }*/

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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let destination = segue.destination as! LessonDetailController
        // Pass the selected object to the new view controller.
        if let lesson = sender as? Lesson{
            destination.lesson = lesson
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
