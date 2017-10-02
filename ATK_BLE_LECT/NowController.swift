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
    
    private func checkTime(){
        
        if checkLesson.checkCurrentLesson() != false{
            
            //Currently has lesson
            lesson = GlobalData.currentLesson
            
        }else if checkLesson.checkNextLesson() != false{
            
            //No lesson currently, show next lesson
            lesson = GlobalData.nextLesson
            
        }else{
            
            //Today no lesson
            
        }
        updateLabels()
        
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
            
        }else if GlobalData.nextLesson.lesson_id != nil{
            
            subject_label.text = (lesson?.subject)! + " " + (lesson?.catalog)!
            class_section_label.text = (lesson?.class_section)!
            time_label.text = displayTime.display(time: (lesson?.start_time)!) + " " + displayTime.display(time: (lesson?.end_time)!)
            location_label.text = (lesson?.location)!
            imageView.image = #imageLiteral(resourceName: "bluetooth_off")
            status_label.text = GlobalData.nextLessonTime
            broadcast_label.isHidden = true
            
        }else{
            
            subject_label.isHidden = true
            class_section_label.isHidden = true
            time_label.isHidden = true
            location_label.isHidden = true
            status_label.font = UIFont.systemFont(ofSize: 24)
            status_label.text = "No lesson today"
            broadcast_label.isHidden = true
            
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
        if imageView.isAnimating{
            imageView.stopAnimating()
            statusBar.backgroundColor = UIColor.clear
            imageView.image = #imageLiteral(resourceName: "bluetooth_on")
            //bluetoothManager.stopAdvertising()
            return
        }

        if GlobalData.currentLesson.lesson_id != nil {
            broadcast()
            statusBar.backgroundColor = UIColor.blue
            statusBar.draw(CGRect(x: CGFloat(1), y: CGFloat(1), width: CGFloat(1), height: CGFloat(1)))
        }
        
    }
    
    @objc func setupTimer(){
        UserDefaults.standard.set("10", forKey: "notification time")
        let date = format.formateDate(format: "HH:mm:ss", date: Date())
        let upcomingLesson = GlobalData.today.filter({$0.start_time! > date})
        for i in upcomingLesson{
            let start_time = format.formatTime(format: "HH:mm:ss", time: i.start_time!)
            let calendar = Calendar.current.dateComponents([.hour,.minute,.second], from: format.formatTime(format: "HH:mm:ss", time: date), to: start_time)
            let time = Int(UserDefaults.standard.string(forKey: "notification time")!)!
            let interval = Double(calendar.hour!*3600 + calendar.minute!*60 + calendar.second! - time*60)
            if interval > 0 {
                let notificationContent = notification.notiContent(title: "Upcoming lesson", body: "\(String(describing: i.catalog!)) \(String(describing: i.class_section!)) \(String(describing: i.location!))")
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
                notification.addNotification(trigger: trigger, content: notificationContent, identifier: String(describing:i.ldateid))
            }
            
        }
        
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        var status = ""
        switch peripheral.state {
        case .poweredOff: status = "Bluetooth Status: \n Turned Off"
        case .poweredOn: status = "Bluetooth Status: \n Turned On"
        case .resetting: status = "Bluetooth Status: \n Resetting"
        case .unauthorized: status = "BLuetooth Status: \n Not Authorized"
        case .unsupported: status = "Bluetooth Status: \n Not Supported"
        default: status = "Bluetooth Status: \n Unknown"
        }
        print(status)
    }
    
    func broadcast() {
        if bluetoothManager.state == .poweredOn {
            guard let statusBar = (UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject).value(forKey: "statusBar") as? UIView
                else {
                    return
                    
            }
            statusBar.backgroundColor = UIColor.white
            statusBar.invalidateIntrinsicContentSize()
            let view = UIView(frame: CGRect(x: 70, y: 0.7, width: 30, height: 4))
            let imageview = UIImageView(image: #imageLiteral(resourceName: "blue_11"))
            imageview.animationImages = [
                #imageLiteral(resourceName: "blue_11"),
                #imageLiteral(resourceName: "blue_22"),
                #imageLiteral(resourceName: "blue_33")
            ]
            imageview.animationDuration = 0.5
            imageview.startAnimating()
            //view.addSubview(imageview)
            view.addSubview(imageview)
            let textview = UILabel()
            textview.text = "transmitting"
            textview.layer.borderWidth = 0.5
            textview.sizeToFit()
            //view.addSubview(textview)
            statusBar.addSubview(view)
            imageView.animationImages = [
                #imageLiteral(resourceName: "blue_1"),
                #imageLiteral(resourceName: "blue_2"),
                #imageLiteral(resourceName: "blue_3")
            ]
            imageView.animationDuration = 0.5
            imageView.startAnimating()
            //broadcast()
            
        }
        else {
            let alert = UIAlertController(title: "Bluetooth Turn on Request", message: " AME would like to turn on your bluetooth!", preferredStyle: UIAlertControllerStyle.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Allow", style: UIAlertActionStyle.default, handler: { action in
                self.turnOnBlt()
                self.broadcast()
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    func turnOnBlt() {
        let url = URL(string: "App-Prefs:root=Bluetooth") //for bluetooth setting
        let app = UIApplication.shared
        app.open(url!, options: ["string":""], completionHandler: nil)
    }
    
    deinit {
        print("deinit is called")
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
