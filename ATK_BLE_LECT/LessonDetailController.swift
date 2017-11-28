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
    @IBOutlet weak var studentLabel: UILabel!
    var internetConnection = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true{
            studentLabel.isHidden = false
            internetConnection = true
            alamofire.loadStudents(lesson: lesson!)
            NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done loading students"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: Notification.Name(rawValue: "done loading students"), object: nil)
        }else{
            studentLabel.isHidden = true
            internetConnection = false
            GlobalData.students.removeAll()
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alert.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        let nib = UINib(nibName: "StudentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        //tableView.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func refreshTable(){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done loading students"), object: nil)
        log.info("refreshing table")
        self.tableView.reloadData()
    }
    
    private func setupLabels(){
        creditTxt.text = String(describing: (lesson?.credit_unit!)!)
        subjectTxt.text = (lesson?.subject)! + " " + (lesson?.catalog)!
        subject_nameTxt.text = (lesson?.subject)! + " " + (lesson?.catalog)!
        groupTxt.text = lesson?.class_section
        timeslotTxt.text = GlobalData.wday[(lesson?.weekday)!]! + " \(displayTime.display(time: (lesson?.start_time!)!))-\(displayTime.display(time: (lesson?.end_time!)!))"
        venueTxt.text = lesson?.location
    }
    
    /*private func calculateCredit(lesson:Lesson) -> Int{
        var credit = 0
        let lessons = GlobalData.timetable.filter({$0.module_id == lesson.module_id})
        for lesson in lessons{
            credit += calTimeDiff(start_time: lesson.start_time!, end_time: lesson.end_time!)
        }
        return credit
        
    }*/
    
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
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        if internetConnection == false{
            title = "No internet connection"
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else {return}
        header.textLabel?.textColor = UIColor.red
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? StudentCell
        cell?.commonInit(studentName: String(indexPath.row + 1) + ". " + GlobalData.students[indexPath.row].name!, status: false)
        return cell!
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
