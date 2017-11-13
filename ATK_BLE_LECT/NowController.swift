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
        NotificationCenter.default.addObserver(self, selector: #selector(setupTimer), name: Notification.Name(rawValue:"stepper changed"), object: nil)
    }
    
    @objc private func checkTime(){
        
        let date = Date()
        self.title = format.formateDate(format: "EEE(dd MMM)", date: date)
        
        self.checkUserInBackground()
        if checkLesson.checkCurrentLesson() != false{
            
            lesson = GlobalData.currentLesson
            let lesson_id = (lesson?.lesson_id)!
            if UserDefaults.standard.string(forKey: "currentLesson") != nil{
                if UserDefaults.standard.string(forKey: "currentLesson")! != String(describing:lesson_id){
                    log.info("current lesson: \(UserDefaults.standard.string(forKey: "currentLesson")!)")
                    log.info("Lesson Id: \(String(describing:lesson?.lesson_id!))")
                }
            }else{
                log.info("First lesson")
                UserDefaults.standard.set(lesson?.lesson_id, forKey: "currentLesson")
                log.info("current lesson: \(UserDefaults.standard.string(forKey: "currentLesson")!)")
                log.info("Lesson Id: \(String(describing:lesson?.lesson_id!))")
                log.info("My name: \(String(describing: UserDefaults.standard.string(forKey: "name")))")
                log.info("Lesson Date Id: \(String(describing: UserDefaults.standard.string(forKey: "current lesson")))")
                log.info("My major: \(String(describing: UserDefaults.standard.string(forKey: "major")))")
                log.info("My minor: \(String(describing: UserDefaults.standard.string(forKey: "minor")))")
            }
            /*Timer.after(1, {
                self.broadcast()
            })*/
            
        }else if checkLesson.checkNextLesson() != false{
            UserDefaults.standard.set("no", forKey: "current lesson")
            //No lesson currently, show next lesson
            lesson = GlobalData.nextLesson
            
        }else{
            UserDefaults.standard.set("no", forKey: "current lesson")
            //Today no lesson
            
        }
        updateLabels()
        
    }
    
    private func checkUserInBackground(){
        
        log.info("Checking user in Background")
        let parameters:[String:Any] = [
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
                    log.info("Lesson Date Id: \(String(describing: UserDefaults.standard.string(forKey: "current lesson")))")
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
        }
        
    }
    
    private func updateLabels(){
        
        if GlobalData.currentLesson.lesson_id != nil{
            
            subject_label.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            class_section_label.text = (lesson?.class_section)!
            time_label.text = displayTime.display(time: (lesson?.start_time)!) + " " + displayTime.display(time: (lesson?.end_time)!)
            location_label.text = (lesson?.location)!
            imageView.image = #imageLiteral(resourceName: "bluetooth_on")
            imageView.isUserInteractionEnabled = true
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
        }

        if GlobalData.currentLesson.lesson_id != nil {
            broadcast()
        }
        
    }
    
    @objc func setupTimer(){
        if UserDefaults.standard.string(forKey: "notification time") == nil{
            UserDefaults.standard.set("10", forKey: "notification time")
        }
        var date = format.formateDate(format: "HH:mm:ss", date: Date())
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
        
        for i in upcomingLesson{
            date = format.formateDate(format: "HH:mm:ss", date: Date())
            let start_time = format.formatTime(format: "HH:mm:ss", time: i.start_time!)
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: format.formatTime(format: "HH:mm:ss", time: date), to: start_time)
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second!)
            if interval > 0 {
                let notificationContent = notification.notiContent(title: "Lesson started", body: "Please open your app to take attendance")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: "lesson start")
            }
            
        }
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var status = ""
        switch peripheral.state {
        case .poweredOff: status = "Bluetooth Status: Turned Off"
        case .poweredOn: status = "Bluetooth Status: Turned On"
        case .resetting: status = "Bluetooth Status: Resetting"
        case .unauthorized: status = "BLuetooth Status: Not Authorized"
        case .unsupported: status = "Bluetooth Status: Not Supported"
        default: status = "Bluetooth Status: Unknown"
        }
        log.info(status)
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
        app.open(url!, options: ["string":""], completionHandler: nil)
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
