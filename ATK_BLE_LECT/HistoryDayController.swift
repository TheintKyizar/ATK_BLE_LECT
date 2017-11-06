//
//  HistoryDayController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/6/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class HistoryDayController: UITableViewController {

    var lesson:Lesson?
    var lessonDates = [LessonDate]()
    
    let spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        tableView.tableFooterView = UIView(frame:.zero)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: "refreshDate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "refreshDate"), object: nil)
        
        spinnerView.center = CGPoint(x: self.view.bounds.width/2, y: self.view.bounds.height/2)
        spinnerView.color = UIColor.black
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshTable(){
        self.spinnerView.removeFromSuperview()
        self.spinnerView.stopAnimating()
        self.tableView.reloadData()
    }
    
    private func setup(){
        
        self.view.addSubview(spinnerView)
        self.spinnerView.startAnimating()
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!
        ]
        Alamofire.request(Constant.URLAllDateOfLesson + String(describing: (lesson?.lesson_id)!), method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [AnyObject]{
                self.lessonDates.removeAll()
                for json in JSON{
                    let newDate = LessonDate()
                    newDate.lesson_date_id = json["id"] as? Int
                    newDate.lesson_date = json["ldate"] as? String
                    newDate.lesson_id = json["lesson_id"] as? Int
                    self.lessonDates.append(newDate)
                }
                log.info("Done loading dates")
                self.lessonDates.sort(by: {$0.lesson_date! > $1.lesson_date!})
                let date = Date()
                let today = format.formateDate(format: "yyyy-MM-dd", date: date)
                self.lessonDates = self.lessonDates.filter({$0.lesson_date! <= today})
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshDate"), object: nil)
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
        return lessonDates.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let title = "\(String(describing: displayTime.display(time: (lesson?.start_time)!)))-\(String(describing: displayTime.display(time: (lesson?.end_time)!)))(\(String(describing: (GlobalData.wday[(lesson?.weekday!)!])!)))"
        return title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "\(String(describing: (lessonDates[indexPath.row].lesson_date)!)) (\(format.formateDate(format: "EEE", date: format.formatTime(format: "yyyy-MM-dd", time: lessonDates[indexPath.row].lesson_date!))))"
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "history_lesson_segue", sender: lessonDates[indexPath.row])
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if let destination = segue.destination as? HistoryLessonController{
            if let lesson_date = sender as? LessonDate{
                destination.lesson_date = lesson_date
            }
        }
        // Pass the selected object to the new view controller.
    }

}
