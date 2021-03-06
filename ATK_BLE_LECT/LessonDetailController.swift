//
//  LessonDetailController.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/5/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire

class LessonDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var lesson:Lesson?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subjectTxt: UILabel!
    @IBOutlet weak var subject_nameTxt: UILabel!
    @IBOutlet weak var creditTxt: UILabel!
    @IBOutlet weak var groupTxt: UILabel!
    @IBOutlet weak var timeslotTxt: UILabel!
    @IBOutlet weak var venueTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        tableView.delegate = self
        tableView.dataSource = self
        alamofire.loadStudents(lesson: lesson!)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "refreshTable+\((lesson?.module_id)!)"), object: nil)
        tableView.autoresizesSubviews = true
        //tableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshTable(){
        print("refreshing")
        self.tableView.reloadData()
    }
    
    private func setupLabels(){
        creditTxt.text = String(calculateCredit(lesson: lesson!))
        subjectTxt.text = (lesson?.subject)! + " " + (lesson?.catalog)!
        subject_nameTxt.text = (lesson?.subject)! + " " + (lesson?.catalog)!
        groupTxt.text = lesson?.class_section
        timeslotTxt.text = GlobalData.wday[(lesson?.weekday)!]! + " \(displayTime.display(time: (lesson?.start_time!)!)) \(displayTime.display(time: (lesson?.end_time!)!))"
        venueTxt.text = lesson?.location
    }
    
    private func calculateCredit(lesson:Lesson) -> Int{
        var credit = 0
        let lessons = GlobalData.timetable.filter({$0.module_id == lesson.module_id})
        for lesson in lessons{
            credit += calTimeDiff(start_time: lesson.start_time!, end_time: lesson.end_time!)
        }
        return credit
        
    }
    
    private func calTimeDiff(start_time:String, end_time:String) -> Int{
        
        let startSplit = start_time.components(separatedBy: ":")
        let sHour = Int(startSplit[0])!
        let endSplit = end_time.components(separatedBy: ":")
        let eHour = Int(endSplit[0])!
        return eHour - sHour
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GlobalData.students.count 
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? StudentCell
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? StudentCell
        cell?.status.isHidden = true
        cell?.studentName.text = GlobalData.students[indexPath.row].name!
        return cell!
    }
    
    /*private func downloadStudents(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any]=[
            "lesson_id" : 13//lesson!.lesson_id!
        ]
        Alamofire.request(Constant.URLGetStudentOfLesson, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [[String:AnyObject]]{
                GlobalData.students.removeAll()
                for json in JSON{
                    let newStudent = Student()
                    newStudent.name = json["name"] as? String
                    newStudent.student_id = json["card"] as? String
                    if let beacon = json["beacon_user"] as? [String:AnyObject]{
                        newStudent.major = beacon["major"] as? Int
                        newStudent.minor = beacon["minor"] as? Int
                    }
                    GlobalData.students.append(newStudent)
                }
                print("Done loading students")
                self.tableView.reloadData()
            }
        }
        
    }*/
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
