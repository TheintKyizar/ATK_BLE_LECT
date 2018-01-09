//
//  AppDelegate.swift
//  ATK_BLE_LECT
//
//  Created by Kyi Zar Theint on 8/30/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
import CoreBluetooth
import SwiftyTimer
import SwiftyBeaver
import UserNotifications
let log = SwiftyBeaver.self
import Foundation
import SystemConfiguration

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var locationManager = CLLocationManager()
    let studentsLimit = 2
    var regionStatus = [String:String]()
    var flag = Bool()
    var commonFlag = Bool()
    var attendanceFlags = [String:String]()
    var refreshingFlag = Bool()
    let file2 = FileDestination()
    private var reachability:Reachability!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        NotificationCenter.default.addObserver(self, selector: #selector(checkForReachability(notification:)), name: ReachabilityChangedNotification, object: nil)
        self.reachability = Reachability.init()
        do{
            try self.reachability.startNotifier()
        }catch{
            log.error(error.localizedDescription)
        }
//        GlobalData.offlineData.removeAll()
//        NSKeyedArchiver.archiveRootObject(GlobalData.offlineData, toFile: filePath.offlineData)
        if UserDefaults.standard.string(forKey: "id") == nil{
            //No user logged in
        }else{
            //User logged in
            self.loadData()
            if let nowController = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "tab_bar_controller") as? UITabBarController{
                window?.rootViewController  = nowController
            }
        }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (success, error) in
            if success{
                log.info("granted noti")
            }else{
                log.info("denided noti")
            }
        }
        
        //add log destinations.
        let console = ConsoleDestination() // log to Xcode Console
        let file = FileDestination() // log to default swiftybeaver.log file
        //let cloud = SBPlatformDestination(appID: "0G8vQ1", appSecret: "ieuq2buxAk4hOpxs6xhekpAizbbdlhsG", encryptionKey: "nFjc1oWmxr3morgyouJrtn1xzd0sNzg4")
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        
        if let url = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first{
            file2.logFileURL = url.appendingPathComponent("attendance.log", isDirectory: false)
        }
        
        //use this for JSON output: console.format = "$J"
        
        //add the destinations to SwifyBeaver
        log.addDestination(console)
        log.addDestination(file)
        //read the swiftybeaver.log file 
        var readString = ""
        //var fileURL = "~/Library/Caches/swiftybeaver.log"
        let CacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = CacheDirURL.appendingPathComponent("swiftybeaver").appendingPathExtension("log")
        let attendanceURL = CacheDirURL.appendingPathComponent("attendance").appendingPathExtension("log")
        //let pathString = fileURL.path
        
        do {
            readString = try String(contentsOf: fileURL)
        }
        catch let error as NSError {
            print("Failed to read file")
            print(error)
        }
        print("@@@@@@@contents of the SwiftyBeaver file \(readString)")
        readString = ""
        do {
            readString = try String(contentsOf: attendanceURL)
        }
        catch let error as NSError{
            print("Failed to read file")
            print(error)
        }
        print("@@@@@@@contents of the attendance file \(readString)")
        return true
    }
    
    @objc func checkForReachability(notification:NSNotification){
        let reachability = notification.object as! Reachability
        if reachability.isReachable{
            if reachability.isReachableViaWiFi{
                print("Reachable via WiFi")
            } else{
                print("Reachable via Cellular")
            }
            //take attendance for offline data
            if let offlineData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.offlineData) as? [Attendance]{
                GlobalData.offlineData = offlineData
                for i in GlobalData.offlineData{
                    self.takeAttendance(ldateId: i.lessonDateID!, studentId: i.studentID!, lecturerId: i.lecturerID!)
                }
            }
            
        }else{
            print("Network not reachable")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            log.debug("inside \(region.identifier)")
            regionStatus[region.identifier] = "inside"
            if region.identifier == "common"{
                commonFlag = true
                if self.backgroundTask == UIBackgroundTaskInvalid{
                    self.registerBackgroundTask()
                }
                Timer.after(2, {
                    if self.commonFlag == true && self.refreshingFlag == false{
                        self.requestStateForMonitoredRegions()
                    }
                })
            }else{
                commonFlag = false
                Constant.identifier = Int(region.identifier)!
                log.debug("Entered specific")
                if attendanceFlags[region.identifier] != "taken"{
                    log.addDestination(file2)
                    log.info("register attendance for \(region.identifier)")
                    log.removeDestination(file2)
                    self.registerAttendance(region: region as! CLBeaconRegion)
                    attendanceFlags[region.identifier] = "taken"
                }
                //self.endBackgroundTask()
                
            }
        case .outside:
            log.debug("Outside bg \(region.identifier)")
            regionStatus[region.identifier] = "outside"
        case .unknown:
            log.debug("UNKNOWN")
            
        }
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    private func checkTime(){
        
        if checkLesson.checkCurrentLesson() != false{
            
            //Currently has lesson
            if isInternetAvailable() == true{
                loadLateStudents()
            }
            
        }else{
            
            self.endBackgroundTask()
            
        }
        
    }
    
    func stopMonitoring(){
        for i in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: i)
        }
        
        log.info("stop monitoring")
        log.info("monnitored regions: \(locationManager.monitoredRegions.count)")
    }
    
    func stopMonitoringSpecific(){
        for i in locationManager.monitoredRegions{
            if i.identifier != "common"{
                locationManager.stopMonitoring(for: i)
            }
        }
        
        log.info("stop monitoring")
        log.info("monitored regions: \(locationManager.monitoredRegions.count)")
    }
    
    func requestStateForMonitoredRegions() {
        flag = true
        let monitoredRegions = Array(locationManager.monitoredRegions)
        // requestState for all regions
        if locationManager.monitoredRegions.count > 0{
            for i in 0...locationManager.monitoredRegions.count - 1{
                if monitoredRegions[i].identifier != "common"{
                    locationManager.requestState(for: monitoredRegions[i])
                }
            }
        }
        refreshingFlag = true
        Timer.after(2) {
            if GlobalData.lateStudents.count > self.studentsLimit{
                self.refreshStudents()
                self.requestStateForMonitoredRegions()
                log.debug("refreshing")
            }
        }
    }
    
    public func uploadLogFile() {
        let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileurl = cacheDirURL.appendingPathComponent("swiftybeaver").appendingPathExtension("log")
        //let pathString = fileurl.path
        let filename = fileurl.lastPathComponent
        print("File Path: \(fileurl.path)")
        print("File name: \(filename)")
        var readString = ""
        do{
            readString = try String(contentsOf: fileurl)
        }
        catch let error as NSError {
            print("Failed to read file")
            print(error)
        }
        print("~~~~~~~~~~~~~~~`Contents of file \(readString)")
        let headers: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        let url = try! URLRequest(url: Constant.URLLogFile, method: .post, headers: headers)
        var data = Data()
        if let fileContents = FileManager.default.contents(atPath: fileurl.path) {
            data = fileContents as Data
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: date)
        let Name = "iOS_\(result)_\((GlobalData.currentLesson.ldateid)!)_\(UserDefaults.standard.string(forKey: "id")!)"
        print("Name&&&&&&&&&&&&&&&&\(Name)")
        Alamofire.upload(multipartFormData: {(MultipartFormData) in
            MultipartFormData.append(data, withName: "logFile", fileName: Name, mimeType: "text/plain")
            /*for (key,_) in parameters {
             let name = String(key)
             if let value = parameters[name] as? String {
             MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
             }
             }*/
            
        }, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    print("MultipartFormData@@@@@@@@@@@@@\(data.endIndex)")
                    print("response.request\(String(describing: response.request))")  // original URL request
                    print("response.response\(String(describing: response.response))" ) // URL response
                    print("response.data\(String(describing: response.data))")     // server data
                    print(response.result)   // result of response serialization
                    //remove the file
                    if response.response?.statusCode == 200{
                        self.deleteLogFile()
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    public func uploadAttendanceLogFile(){
        let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileurl = cacheDirURL.appendingPathComponent("attendance").appendingPathExtension("log")
        //let pathString = fileurl.path
        let filename = fileurl.lastPathComponent
        print("File Path: \(fileurl.path)")
        print("File name: \(filename)")
        var readString = ""
        do{
            readString = try String(contentsOf: fileurl)
        }
        catch let error as NSError {
            print("Failed to read file")
            print(error)
        }
        print("~~~~~~~~~~~~~~~`Contents of file \(readString)")
        let headers: HTTPHeaders = [
            "Content-Type" : "multipart/form-data"
        ]
        
        let url = try! URLRequest(url: Constant.URLLogFile, method: .post, headers: headers)
        var data = Data()
        if let fileContents = FileManager.default.contents(atPath: fileurl.path) {
            data = fileContents as Data
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: date)
        let Name = "iOS_\(result)_\((GlobalData.currentLesson.ldateid)!)_\(UserDefaults.standard.string(forKey: "id")!)_attendance"
        print("Name&&&&&&&&&&&&&&&&\(Name)")
        Alamofire.upload(multipartFormData: {(MultipartFormData) in
            MultipartFormData.append(data, withName: "logFile", fileName: Name, mimeType: "text/plain")
            /*for (key,_) in parameters {
             let name = String(key)
             if let value = parameters[name] as? String {
             MultipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
             }
             }*/
            
        }, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON {
                    response in
                    print("MultipartFormData@@@@@@@@@@@@@\(data.endIndex)")
                    print("response.request\(String(describing: response.request))")  // original URL request
                    print("response.response\(String(describing: response.response))" ) // URL response
                    print("response.data\(String(describing: response.data))")     // server data
                    print(response.result)   // result of response serialization
                    //remove the file
                    if response.response?.statusCode == 200{
                        self.deleteLogFile()
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
            }
        })
    }
    
    func deleteLogFile(){
        let file = FileDestination()
        let _  = file.deleteLogFile()
    }
    
    func deleteAttendanceLogFile(){
        let file = FileDestination()
        if let url = FileManager.default.urls(for:.cachesDirectory, in: .userDomainMask).first{
            file.logFileURL = url.appendingPathComponent("attendance.log", isDirectory: false)
        }
        let _ = file.deleteLogFile()
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.debug("Started monitoring \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        
        log.debug("Stop monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            log.debug("did exit region!!! \(region.identifier)")
            if region.identifier != "common"{
                if regionStatus[region.identifier] == "inside"{
                    regionStatus[region.identifier] = "outside"
                    locationManager.stopMonitoring(for: region)
                    GlobalData.regionExitFlag = true
                    //self.requestStateForMonitoredRegions()
                }
            }else{
                regionStatus[region.identifier] = "outside"
                refreshingFlag = false
                self.endBackgroundTask()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            log.debug("did enter region!!! \(region.identifier)")
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active{
            completionHandler([])
        }else{
            completionHandler([.alert,.badge,.sound])
        }
    }
    
    func loadLateStudents() {
        GlobalData.lateStudents.removeAll()
        GlobalData.studentStatus.removeAll()
        let lesson_date = LessonDate()
        lesson_date.lesson_date = GlobalData.currentLesson.ldate
        lesson_date.lesson_date_id = GlobalData.currentLesson.ldateid
        lesson_date.lesson_id = GlobalData.currentLesson.lesson_id
        loadStudentsNStatus(lesson: GlobalData.currentLesson, lesson_date: lesson_date, returnString: "loadLateStudents")
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"loadLateStudents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doneLoadingStudentsAndStatus), name: Notification.Name(rawValue: "loadLateStudents"), object: nil)
        
    }
    
    private func loadStudentsNStatus(lesson:Lesson, lesson_date:LessonDate, returnString:String){
        GlobalData.lesson_id = String(describing: lesson.lesson_id)
        log.info("Lesson_id : \(String(describing: lesson.lesson_id!))")
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any]=[
            "lesson_id" : lesson.lesson_id!//13
        ]
        Alamofire.request(Constant.URLGetStudentOfLesson, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            if let code = response.response?.statusCode{
                if code == 200{
                    if let JSON = response.result.value as? [[String:AnyObject]]{
                        GlobalData.students.removeAll()
                        for json in JSON{
                            let newStudent = Student()
                            newStudent.name = json["name"] as? String
                            newStudent.student_card = json["card"] as? String
                            newStudent.student_id = json["id"] as? Int
                            if let beacon = json["beacon_user"] as? [String:AnyObject]{
                                newStudent.major = beacon["major"] as? Int
                                newStudent.minor = beacon["minor"] as? Int
                            }
                            GlobalData.students.append(newStudent)
                        }
                        print("Done loading students")
                        NSKeyedArchiver.archiveRootObject(GlobalData.students, toFile: filePath.studentPath)
                        GlobalData.ldate_id = String(describing:lesson_date.lesson_date_id!)
                        log.info("Lesson date Id: \(lesson_date.lesson_date_id ?? 0)")
                        let parameters:[String:Any]=[
                            "lesson_date_id" : lesson_date.lesson_date_id!
                        ]
                        Alamofire.request(Constant.URLAtkStatus, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response2:DataResponse) in
                            if let code2 = response2.response?.statusCode{
                                if code2 == 200{
                                    let notificationContent = notification.notiContent(title: "Monitoring status", body: "Started monitoring")
                                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                    notification.addNotification(trigger: trigger, content: notificationContent, identifier: "monitor started")
                                    if let JSON = response2.result.value as? [[String:AnyObject]]{
                                        GlobalData.studentStatus.removeAll()
                                        for json in JSON{
                                            let newStatus = Status()
                                            newStatus.recorded_time = json["recorded_time"] as? String
                                            newStatus.status = json["status"] as? Int
                                            newStatus.student_id = json["student_id"] as? Int
                                            GlobalData.studentStatus.append(newStatus)
                                        }
                                        log.info("done loading student's status")
                                        NSKeyedArchiver.archiveRootObject(GlobalData.studentStatus, toFile: filePath.historyPath)
                                        NotificationCenter.default.post(name: Notification.Name(rawValue: returnString), object: nil)
                                    }
                                }else{
                                    
                                    //Has error, try login
                                    
                                    let username = UserDefaults.standard.string(forKey: "username")
                                    let password = UserDefaults.standard.string(forKey: "password")
                                    let device_hash = UIDevice.current.identifierForVendor?.uuidString
                                    
                                    let parameters:[String:Any] = [
                                        "username" : username!,
                                        "password" : password!,
                                        "device_hash" : device_hash!
                                    ]
                                    
                                    Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                                        
                                        let code = response.response?.statusCode
                                        if code == 200{
                                            
                                            if let JSON = response.result.value as? [String:AnyObject]{
                                                
                                                Constant.lecturer_id = JSON["id"] as! Int
                                                Constant.name = JSON["name"] as! String
                                                Constant.token = JSON["token"] as! String
                                                Constant.major = JSON["major"] as! UInt16
                                                Constant.minor = JSON["minor"] as! UInt16
                                                
                                                UserDefaults.standard.set(Constant.lecturer_id, forKey: "id")
                                                UserDefaults.standard.set(Constant.name, forKey: "name")
                                                UserDefaults.standard.set(Constant.token, forKey: "token")
                                                UserDefaults.standard.set(Constant.major, forKey: "major")
                                                UserDefaults.standard.set(Constant.minor, forKey: "minor")
                                                
                                                if let office = JSON["office"] as? String{
                                                    UserDefaults.standard.set(office, forKey: "office")
                                                }else{
                                                    UserDefaults.standard.removeObject(forKey: "office")
                                                }
                                                if let email = JSON["email"] as? String{
                                                    UserDefaults.standard.set(email, forKey: "email")
                                                }else{
                                                    UserDefaults.standard.removeObject(forKey: "email")
                                                }
                                                if let phone = JSON["phone"] as? String{
                                                    UserDefaults.standard.set(phone, forKey: "phone")
                                                }else{
                                                    UserDefaults.standard.removeObject(forKey: "phone")
                                                }
                                                self.loadLateStudents()
                                            }
                                            
                                        }else{
                                            
                                            let notificationContent = notification.notiContent(title: "Monitoring Error", body: "Please relaunch the app to begin monitoring")
                                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                                            notification.addNotification(trigger: trigger, content: notificationContent, identifier: "monitor error")
                                            
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                }else{
                    
                    //has error, try login
                    let username = UserDefaults.standard.string(forKey: "username")
                    let password = UserDefaults.standard.string(forKey: "password")
                    let device_hash = UIDevice.current.identifierForVendor?.uuidString
                    
                    let parameters:[String:Any] = [
                        "username" : username!,
                        "password" : password!,
                        "device_hash" : device_hash!
                    ]
                    
                    Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
                        
                        let code = response.response?.statusCode
                        if code == 200{
                            
                            if let JSON = response.result.value as? [String:AnyObject]{
                                
                                Constant.lecturer_id = JSON["id"] as! Int
                                Constant.name = JSON["name"] as! String
                                Constant.token = JSON["token"] as! String
                                Constant.major = JSON["major"] as! UInt16
                                Constant.minor = JSON["minor"] as! UInt16
                                
                                UserDefaults.standard.set(Constant.lecturer_id, forKey: "id")
                                UserDefaults.standard.set(Constant.name, forKey: "name")
                                UserDefaults.standard.set(Constant.token, forKey: "token")
                                UserDefaults.standard.set(Constant.major, forKey: "major")
                                UserDefaults.standard.set(Constant.minor, forKey: "minor")
                                
                                if let office = JSON["office"] as? String{
                                    UserDefaults.standard.set(office, forKey: "office")
                                }else{
                                    UserDefaults.standard.removeObject(forKey: "office")
                                }
                                if let email = JSON["email"] as? String{
                                    UserDefaults.standard.set(email, forKey: "email")
                                }else{
                                    UserDefaults.standard.removeObject(forKey: "email")
                                }
                                if let phone = JSON["phone"] as? String{
                                    UserDefaults.standard.set(phone, forKey: "phone")
                                }else{
                                    UserDefaults.standard.removeObject(forKey: "phone")
                                }
                                self.loadLateStudents()
                                
                            }
                            
                        }else{
                            
                            let notificationContent = notification.notiContent(title: "Monitoring Error", body: "Please relaunch the app to begin monitoring")
                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                            notification.addNotification(trigger: trigger, content: notificationContent, identifier: "monitor error")
                            
                        }
                        
                    }
                    
                }
            }
        }
    }
    
    @objc func doneLoadingStudentsAndStatus(){
        self.getLateStudents()
    }
    
    private func getLateStudents() {
        if GlobalData.studentStatus.count > 0 {
            for i in 0...GlobalData.studentStatus.count-1 {
                if GlobalData.students[i].student_id != nil{
                    if(GlobalData.studentStatus[i].status == -1) {
                        GlobalData.lateStudents.append(GlobalData.students.filter({$0.student_id! == GlobalData.studentStatus[i].student_id!}).first!)
                    }
                }
            }
        }else{
            UserDefaults.standard.removeObject(forKey: "background monitor")
        }
        self.monitor()
    }
    
    func monitor() {
        
        refreshingFlag = false
        
        for i in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: i)
        }
        
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        if GlobalData.lateStudents.count > 0{
            log.info("Lesson uuid: " + String(describing: uuid!))
            let commonRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
            var count = 0
            locationManager.startMonitoring(for: commonRegion)
            
            if (GlobalData.lateStudents.count % studentsLimit) > 0{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit) + 1
            }else{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit)
            }
            
            Constant.currentGroup = 1
            for i in 0...GlobalData.lateStudents.count-1{
                if count < studentsLimit{
                    log.info("Student Name: " + String(describing: GlobalData.lateStudents[i].name!))
                    log.info("Student Id: " + String(describing: GlobalData.lateStudents[i].student_id!))
                    log.info("minor: " + String(describing: GlobalData.lateStudents[i].minor!))
                    log.info("major: " + String(describing: GlobalData.lateStudents[i].major!))
                    
                    let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i].major!), minor: UInt16(GlobalData.lateStudents[i].minor!), identifier: String(GlobalData.lateStudents[i].student_id!))
                    if i<19{
                        locationManager.startMonitoring(for: newRegion)
                        GlobalData.regions.append(newRegion)
                    }
                }
                count += 1
            }
            locationManager.requestState(for: commonRegion)
        }else{
            self.endBackgroundTask()
        }
        
    }
    
    func reMonitor(){
        refreshingFlag = false
        
        for i in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: i)
        }
        
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        if GlobalData.lateStudents.count > 0{
            log.info("Lesson uuid: " + String(describing: uuid!))
            let commonRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
            locationManager.startMonitoring(for: commonRegion)
            
            if (GlobalData.lateStudents.count % studentsLimit) > 0{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit) + 1
            }else{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit)
            }
            
            if Constant.currentGroup > Constant.studentGroup{
                Constant.currentGroup = 1
            }
            
            let start = (Constant.currentGroup - 1)*studentsLimit
            if (GlobalData.lateStudents.count - start) > studentsLimit{
                for i in 0...studentsLimit-1{
                    let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                    locationManager.startMonitoring(for: newRegion)
                    GlobalData.regions.append(newRegion)
                }
            }else{
                if GlobalData.lateStudents.count > 0 {
                    for i in 0...(GlobalData.lateStudents.count - start) - 1{
                        let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                        locationManager.startMonitoring(for: newRegion)
                        GlobalData.regions.append(newRegion)
                    }
                }
            }
            
            locationManager.requestState(for: commonRegion)
        }else{
            self.endBackgroundTask()
        }
    }
    
    private func refreshStudents(){
        log.info("Refreshing Student lists")
        log.info("Current group: \(Constant.currentGroup)")
        log.info("Total group: \(Constant.studentGroup)")
        self.stopMonitoringSpecific()
        let state = Constant.studentGroup
        var check = Bool()
        for i in 1...state{
            if Constant.currentGroup == i{
                if i == state && check == false{
                    Constant.currentGroup = 1
                    check = true
                }else{
                    if check == false{
                        Constant.currentGroup = i + 1
                        check = true
                    }
                }
            }
        }
        log.info("Next group \(Constant.currentGroup)")
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        let start = (Constant.currentGroup - 1)*studentsLimit
        if (GlobalData.lateStudents.count - start) > studentsLimit{
            for i in 0...studentsLimit-1{
                let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                locationManager.startMonitoring(for: newRegion)
                GlobalData.regions.append(newRegion)
            }
        }else{
            if GlobalData.lateStudents.count > 0 {
                for i in 0...(GlobalData.lateStudents.count - start) - 1{
                    let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                    locationManager.startMonitoring(for: newRegion)
                    GlobalData.regions.append(newRegion)
                }
            }
        }
        
        //locationManager.requestState(for: newRegion)
    }
    
    private func registerAttendance(region:CLBeaconRegion){
        let lecturer_id = UserDefaults.standard.integer(forKey: "id") as! Int
        if isInternetAvailable() == true{
            self.takeAttendance(ldateId: GlobalData.currentLesson.ldateid!, studentId: Constant.identifier, lecturerId: lecturer_id)
        }else{
            let newAttendance = Attendance(lessonDateId: GlobalData.currentLesson.ldateid!, studentId: Constant.identifier, lecturerId: lecturer_id)
            
            if let offlineData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.offlineData) as? [Attendance]{
                GlobalData.offlineData = offlineData
                if GlobalData.offlineData.filter({$0.studentID==newAttendance.studentID}).first == nil{
                    GlobalData.offlineData.append(newAttendance)
                }
            }else{
                GlobalData.offlineData.append(newAttendance)
            }
            
            NSKeyedArchiver.archiveRootObject(GlobalData.offlineData, toFile: filePath.offlineData)
        }
    }
    
    private func removeAttendance(attendance:Attendance){
        GlobalData.offlineData = GlobalData.offlineData.filter({$0.studentID != attendance.studentID})
        NSKeyedArchiver.archiveRootObject(GlobalData.offlineData, toFile: filePath.offlineData)
    }
    
    func takeAttendance(ldateId:Int,studentId:Int,lecturerId:Int) {
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        Constant.lecturer_id = UserDefaults.standard.integer(forKey: "id")
        
        let para1: Parameters = [
            "lesson_date_id": ldateId,
            "student_id": studentId,
            "lecturer_id": lecturerId,
            ]
        let parameters: [String: Any] = ["data": [para1]]
        
        log.info("parameters: " + String(describing: parameters))
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constant.URLCreateAtk, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            let statusCode = response.response?.statusCode
            if (statusCode == 200){
                log.info("Attendance taken successful\(studentId)")
                print("GlobalData.lateStudents: \(GlobalData.lateStudents.count)")
                self.removeAttendance(attendance: Attendance(lessonDateId: ldateId, studentId: studentId, lecturerId: lecturerId))
                if let student = GlobalData.lateStudents.filter({$0.student_id == studentId}).first{
                    GlobalData.lateStudents = GlobalData.lateStudents.filter({$0.student_id != student.student_id!})
                    log.addDestination(self.file2)
                    log.info("attendance taking successful for \(studentId)")
                    log.removeDestination(self.file2)
                    self.reMonitor()
                }
            }
            if let data = response.result.value{
                log.info("///////////////result below////////////")
                log.info(data)
            }
            
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        log.debug("application will resign active")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationWillEnterBackground(_ application: UIApplication) {
        log.info("will enter background")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        log.debug("did enter background")
        registerBackgroundTask()
        checkTime()
    }
    
    func registerBackgroundTask() {
        log.debug("registered backgroundTask")
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        refreshingFlag = false
        log.info("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue:"update time"), object: nil)
        attendanceFlags.removeAll()
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        log.info("application will terminate")
    }
    
    private func loadData(){
        
        if let weeklyTimetable = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.weeklyTimetable) as? [Lesson]{
            GlobalData.weeklyTimetable = weeklyTimetable
        }
        
        if let timeTable = NSKeyedUnarchiver.unarchiveObject(withFile: filePath.timetablePath) as? [Lesson]{
            GlobalData.timetable = timeTable
        }
        
    }
}

