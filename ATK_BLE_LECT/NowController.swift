//
//  NowViewController.swift
//  ATK_BLE_LECT
//
//  Created by Kyi Zar Theint on 8/31/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import UserNotifications
import CoreBluetooth
import CoreLocation
import Alamofire

class NowController: UIViewController, UNUserNotificationCenterDelegate, CLLocationManagerDelegate, CBPeripheralManagerDelegate {
    
    var locationManager = CLLocationManager()
    var bluetoothManager = CBPeripheralManager()
    var uuid:UUID!
    var dataDictionary = NSDictionary()
    
    
    @IBOutlet weak var subject_label: UILabel!
    @IBOutlet weak var class_section_label: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var location_label: UILabel!
    @IBOutlet weak var broadcast_label: UILabel!
    @IBOutlet weak var status_label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var lesson:Lesson?
    @IBAction func beaconButton(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        self.addObserver()
        locationManager.delegate = self
        bluetoothManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        setupImageView()
        checkTime()
        setupTimer() //Upcoming lessons
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func addObserver(){
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: Notification.Name(rawValue:"update time"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkTime), name: Notification.Name(rawValue:"timetable changed"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupTimer), name: Notification.Name(rawValue:"stepper changed"), object: nil)
    }
    
    @objc private func checkTime(){
        
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways:
                break
            default:
                let alertController = UIAlertController(title: "Location Services", message: "Please always allow location services for background functions", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                        // If general location settings are disabled then open general location settings
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
                alertController.addAction(action)
                self.present(alertController, animated: false, completion: nil)
            }
        }else{
            //location Services off
            let alertController = UIAlertController(title: "Location Services", message: "Please always allow location services for background functions", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
                    // If general location settings are disabled then open general location settings
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            alertController.addAction(action)
            self.present(alertController, animated: false, completion: nil)
        }
        
        let date = Date()
        self.title = format.formateDate(format: "EEE(dd MMM)", date: date)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if let currentLessonDateId = UserDefaults.standard.string(forKey: "current lesson date id"){
            GlobalData.currentLesson.ldateid = Int(currentLessonDateId)
            if let timeString = (GlobalData.weeklyTimetable.filter({$0.ldateid == Int(currentLessonDateId)}).first?.start_time!){
                let start_time = format.formatTime(format: "HH:mm:ss", time: timeString)
                let timeInterval = format.formatTime(format: "HH:mm:ss", time: format.formateDate(format: "HH:mm:ss", date: Date())).timeIntervalSince(start_time)
                if timeInterval >= 5400{
                    if UserDefaults.standard.string(forKey: "\(currentLessonDateId) log file") == nil{
                        let appdelegate = UIApplication.shared.delegate as! AppDelegate
                        UserDefaults.standard.set("true", forKey: "\(currentLessonDateId) log file")
                        appdelegate.uploadLogFile()
                        appdelegate.uploadAttendanceLogFile()
                    }
                }
            }
            
        }
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if appdelegate.isInternetAvailable() == true{
            self.checkUserInBackground()
        }else{
            let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                alert.dismiss(animated: false, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        if checkLesson.checkCurrentLesson() != false{
            
            if bluetoothManager.state == .poweredOff{
                let alertController = UIAlertController(title: "Bluetooth required", message: "Please turn on bluetooth to take attendance", preferredStyle: .alert )
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: false, completion: nil)
            }
            
            UserDefaults.standard.set(GlobalData.currentLesson.ldateid, forKey: "current lesson date id")
            
            lesson = GlobalData.currentLesson
            let lesson_id = (lesson?.lesson_id)!
            
            let notificationContent = notification.notiContent(title: "Bluetooth required", body: "Please turn on bluetooth to take attendance")
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            notification.addNotification(trigger: trigger, content: notificationContent, identifier: "bluetooth")
            
            if UserDefaults.standard.string(forKey: "currentLesson") != nil{
                
                if UserDefaults.standard.string(forKey: "currentLesson")! != String(describing:lesson_id){
                    UserDefaults.standard.set((lesson?.lesson_id!)!, forKey: "currentLesson")
                    appDelegate.stopMonitoring()
                }
            }else{
                log.info("First lesson")
                UserDefaults.standard.set((lesson?.lesson_id)!, forKey: "currentLesson")
            }
            
            Timer.after(1, {
                let timeInterval = format.formatTime(format: "HH:mm:ss", time: format.formateDate(format: "HH:mm:ss", date: Date())).timeIntervalSince(format.formatTime(format: "HH:mm:ss", time: (self.lesson?.start_time!)!))
                if timeInterval < 0{
                    self.broadcast()
                }else{
                    appdelegate.loadLateStudents()
                }
            })
            
            
        }else if checkLesson.checkNextLesson() != false{
            UserDefaults.standard.set("no", forKey: "currentLesson")
            UserDefaults.standard.removeObject(forKey: "current lesson date id")
            //No lesson currently, show next lesson
            nextLessonRefresh()
            lesson = GlobalData.nextLesson
            appDelegate.stopMonitoring()
            
        }else{
            UserDefaults.standard.set("no", forKey: "currentLesson")
            UserDefaults.standard.removeObject(forKey: "current lesson date id")
            appDelegate.stopMonitoring()
            //Today no lesson
            
        }
        updateLabels()
        
    }
    
    private func checkUserInBackground(){
        
        log.info("Checking user in Background")
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization":"Bearer " + token!,
            "Content-Type":"application/json"
        ]
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: self.view.frame.width/2,y: self.view.frame.height/2)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        self.view.addSubview(spinnerIndicator)
        Alamofire.request(Constant.URLWeeklyTimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            let code = (response.response?.statusCode)!
            spinnerIndicator.removeFromSuperview()
            log.info("Status code: " + String(describing: code))
            if code >= 400 && code < 500{
                let alertView = UIAlertController(title: "Section time out", message: "Your sign in section is expired", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    self.performSegue(withIdentifier: "sign_in_segue", sender: nil)
                })
                alertView.addAction(action)
                self.present(alertView, animated: false, completion: nil)
            }else if code == 200{
                if let JSON = response.result.value as? [AnyObject]{
                    GlobalData.weeklyTimetable.removeAll()
                    for json in JSON{
                        let newLesson = Lesson()
                        if let lesson = json["lesson"] as? [String:Any]{
                            newLesson.lesson_id = lesson["id"] as? Int
                            newLesson.module_id = lesson["module_id"] as? String
                            newLesson.subject = lesson["subject_area"] as? String
                            newLesson.catalog = lesson["catalog_number"] as? String
                            newLesson.class_section = lesson["class_section"] as? String
                            newLesson.weekday = lesson["weekday"] as? String
                            newLesson.start_time = lesson["start_time"] as? String
                            newLesson.end_time = lesson["end_time"] as? String
                            newLesson.credit_unit = Int((lesson["credit_unit"] as? String)!)
                        }
                        
                        if let lesson_date = json["lesson_date_weekly"] as? [String:Any]{
                            newLesson.ldate = lesson_date["ldate"] as? String
                            newLesson.ldateid = lesson_date["id"] as? Int
                        }
                        
                        if let venue = json["venue"] as? [String:Any]{
                            newLesson.location = venue["location"] as? String
                            newLesson.venueName = venue["name"] as? String
                        }
                        if let beacon = json["beacon_lesson"] as? [String:Any]{
                            newLesson.uuid = beacon["uuid"] as? String
                        }
                        GlobalData.weeklyTimetable.append(newLesson)
                    }
                    log.info("Done refreshing timetable")
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "done loading timetable"), object: nil)
                    NSKeyedArchiver.archiveRootObject(GlobalData.weeklyTimetable, toFile: filePath.weeklyTimetable)
                }
            }
        }
        
        /*let parameters:[String:Any] = [
            "username" : UserDefaults.standard.string(forKey: "username")!,
            "password" : UserDefaults.standard.string(forKey: "password")!
        ]
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinnerIndicator.center = CGPoint(x: self.view.frame.width/2,y: self.view.frame.height/2)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        self.view.addSubview(spinnerIndicator)
        Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            let code = response.response?.statusCode
            spinnerIndicator.removeFromSuperview()
            log.info("Login Status code: " + String(describing: code!))
            if code == 200{
                if let json = response.result.value as? [String:AnyObject]{
                    UserDefaults.standard.set(json["token"], forKey: "token")
                    log.info("current lesson: \(UserDefaults.standard.string(forKey: "currentLesson")!)")
                    log.info("My name: \(String(describing: UserDefaults.standard.string(forKey: "name")))")
                    log.info("Lesson Date Id: \(String(describing: UserDefaults.standard.string(forKey: "currentLesson")))")
                    log.info("My major: \(String(describing: UserDefaults.standard.string(forKey: "major")))")
                    log.info("My minor: \(String(describing: UserDefaults.standard.string(forKey: "minor")))")
                    
                }
            }else{
                let alertView = UIAlertController(title: "Section time out", message: "Your sign in section is expired", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action:UIAlertAction) in
                    self.performSegue(withIdentifier: "sign_in_segue", sender: nil)
                })
                alertView.addAction(action)
                self.present(alertView, animated: false, completion: nil)
            }
        }*/
        
    }
    
    private func updateLabels(){
        
        if GlobalData.currentLesson.lesson_id != nil{
            
            subject_label.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            class_section_label.text = (lesson?.class_section)!
            time_label.text = displayTime.display(time: (lesson?.start_time)!) + " " + displayTime.display(time: (lesson?.end_time)!)
            location_label.text = (lesson?.location)!
            imageView.image = #imageLiteral(resourceName: "bluetooth_on")
            imageView.isUserInteractionEnabled = true
            imageView.isHidden = false
            status_label.text = ""
            broadcast_label.text = "Broadcast My Beacon"
            subject_label.isHidden = false
            class_section_label.isHidden = false
            time_label.isHidden = false
            location_label.isHidden = false
            broadcast_label.isHidden = false
            status_label.isHidden = false
            
        }else if GlobalData.nextLesson.lesson_id != nil{
            
            subject_label.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            class_section_label.text = (lesson?.class_section)!
            time_label.text = displayTime.display(time: (lesson?.start_time)!) + " " + displayTime.display(time: (lesson?.end_time)!)
            location_label.text = (lesson?.location)!
            imageView.image = #imageLiteral(resourceName: "bluetooth_off")
            imageView.isHidden = false
            status_label.text = GlobalData.nextLessonTime
            broadcast_label.isHidden = true
            subject_label.isHidden = false
            class_section_label.isHidden = false
            time_label.isHidden = false
            location_label.isHidden = false
            status_label.isHidden = false
            
        }else{
            
            subject_label.isHidden = true
            class_section_label.isHidden = true
            time_label.isHidden = true
            location_label.isHidden = true
            status_label.font = UIFont.systemFont(ofSize: 24)
            status_label.text = "No lesson today"
            broadcast_label.isHidden = true
            imageView.isHidden = true
            
        }
        
    }
    
    private func setupImageView(){
        
        imageView.isUserInteractionEnabled = false
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(broadcastSignal))
        singleTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(singleTap)
        
    }
    
    @objc private func stopBroadcast(){
        imageView.stopAnimating()
        imageView.isUserInteractionEnabled = false
    }
    
    @objc private func broadcastSignal() {
        guard let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView
            else { return }
        
        if statusBar.subviews.count >= 3{
            statusBar.subviews[2].removeFromSuperview()
        }
        
        if imageView.isAnimating{
            imageView.stopAnimating()
            statusBar.backgroundColor = UIColor.clear
            imageView.image = #imageLiteral(resourceName: "bluetooth_on")
            bluetoothManager.stopAdvertising()
            log.debug("Stop broadcasting...")
            return
        }else{
            broadcast()
        }
        
        /*if GlobalData.currentLesson.lesson_id != nil {
            
        }*/
        
    }
    
    @objc func setupTimer(){
        if UserDefaults.standard.string(forKey: "notification time") == nil{
            UserDefaults.standard.set("10", forKey: "notification time")
        }
        let date = format.formateDate(format: "HH:mm:ss", date: Date())
        let upcomingLesson = GlobalData.today.filter({$0.start_time! > date})
        for i in upcomingLesson{
            let start_time = format.formatTime(format: "HH:mm:ss", time: i.start_time!)
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: format.formatTime(format: "HH:mm:ss", time: date), to: start_time)
            let time = Int(UserDefaults.standard.string(forKey: "notification time")!)!
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - time*60)
            if interval > 0{
                let notificationContent = notification.notiContent(title: "Upcoming lesson", body: "\(String(describing: i.catalog!)) \(String(describing: i.class_section!)) \(String(describing:i.location!))")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: String(describing:i.ldateid))
            }
        }
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var status = ""
        switch peripheral.state {
        case .poweredOff: status = "Bluetooth Status: Turned Off"
            if checkLesson.checkCurrentLesson() != false{
                let notificationContent = notification.notiContent(title: "Bluetooth required", body: "Please turn on bluetooth to take attendance")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: "bluetooth")
            }
        case .poweredOn: status = "Bluetooth Status: Turned On"
        case .resetting: status = "Bluetooth Status: Resetting"
        case .unauthorized: status = "BLuetooth Status: Not Authorized"
        case .unsupported: status = "Bluetooth Status: Not Supported"
        default: status = "Bluetooth Status: Unknown"
        }
        log.info(status)
    }
    
    private func nextLessonRefresh(){
        let nLesson = GlobalData.nextLesson
        let date = format.formateDate(format: "HH:mm:ss", date: Date())
        let start_time = format.formatTime(format: "HH:mm:ss", time: nLesson.start_time!)
        let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: format.formatTime(format: "HH:mm:ss", time: date),to: start_time)
        let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - 600)
        if interval > 0 {
            
            let nTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(checkTime), userInfo: nil, repeats: false)
            RunLoop.main.add(nTimer, forMode: RunLoopMode.commonModes)
            
        }
        
    }
    
    func broadcast() {
        if bluetoothManager.state == .poweredOn {
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if appdelegate.isInternetAvailable() == true {
                imageView.animationImages = [
                    #imageLiteral(resourceName: "blue_1"),
                    #imageLiteral(resourceName: "blue_2"),
                    #imageLiteral(resourceName: "blue_3")
                ]
                imageView.animationDuration = 0.5
                imageView.startAnimating()
                
                let major = UInt16(Int(UserDefaults.standard.string(forKey: "major")!)!)as CLBeaconMajorValue
                let minor = UInt16(Int(UserDefaults.standard.string(forKey: "minor")!)!)as CLBeaconMinorValue
                uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!) as UUID?
                log.info("Lesson uuid: " + String(describing: uuid))
                log.info("minor: " + String(describing:minor))
                log.info("major: " + String(describing:major))
                let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: major, minor: minor, identifier: "\(String(describing: UserDefaults.standard.string(forKey: "id")!))")
                dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
                bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
                log.debug("broadcasting...")
            }
            else {
                let alert = UIAlertController(title: "Internet turn on request", message: "Please make sure that your phone has internet connection! ", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
            }
        }
        else {
            let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " Please turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                //self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    private func turnOnData() {
        let url = URL(string: "App-Prefs:root=WIFI") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    func turnOnBlt() {
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: [:], completionHandler: nil)
    }
    
    deinit {
        log.info("deinit is called")
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
struct displayTime {
    static func display(time: String) -> String{
        let timeSplit = time.components(separatedBy: ":")
        let hour = timeSplit[0]
        let minute = timeSplit[1]
        return hour + ":" + minute
    }
}
