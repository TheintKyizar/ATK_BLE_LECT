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
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
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
        let cloud = SBPlatformDestination(appID: "0G8vQ1", appSecret: "ieuq2buxAk4hOpxs6xhekpAizbbdlhsG", encryptionKey: "nFjc1oWmxr3morgyouJrtn1xzd0sNzg4")
        // use custom format and set console output to short time, log level & message
        console.format = "$DHH:mm:ss$d $L $M"
        //use this for JSON output: console.format = "$J"
        
        //add the destinations to SwifyBeaver
        log.addDestination(console)
        log.addDestination(file)
        log.addDestination(cloud)
        //Do log
        /*log.verbose("not so important")  // prio 1, VERBOSE in silver
        log.debug("something to debug")  // prio 2, DEBUG in green
        log.info("a nice information")   // prio 3, INFO in blue
        log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
        log.error("ouch, an error did occur!")  // prio 5, ERROR in red
        
        // log anything!
        log.verbose(123)
        log.info(-123.45678)
        log.warning(Date())
        log.error(["I", "like", "logs!"])
        log.error(["name": "Mr Beaver", "address": "7 Beaver Lodge"])*/
        
        //read the swiftybeaver.log file 
        var readString = ""
        //var fileURL = "~/Library/Caches/swiftybeaver.log"
        let CacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let fileURL = CacheDirURL.appendingPathComponent("swiftybeaver").appendingPathExtension("log")
        //let pathString = fileURL.path
        
        do {
            readString = try String(contentsOf: fileURL)
        }
        catch let error as NSError {
            log.info("Failed to read file")
            log.info(error)
        }
        //log.info("@@@@@@@contents of the file \(readString)")
        
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            log.debug("inside \(region.identifier)")
            regionStatus[region.identifier] = "inside"
            if region.identifier == "common"{
                commonFlag = true
                Timer.after(2, {
                    if self.commonFlag == true{
                        self.requestStateForMonitoredRegions()
                        
                    }
                })
            }else{
                commonFlag = false
                Constant.identifier = Int(region.identifier)!
                log.debug("Entered specific")
                takeAttendance()
                NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"taken+\(Constant.identifier)"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(takensuccess(region:)), name: Notification.Name(rawValue: "taken+\(Constant.identifier)"), object: region)
                
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
            loadLateStudents()
            
        }else{
            
           // endBackgroundTask()
            
        }
        
    }
    
    private func stopMonitoring(){
        for i in locationManager.monitoredRegions{
            if i.identifier != "common"{
                locationManager.stopMonitoring(for: i)
            }
        }
        
        log.info("stop monitoring")
        log.info("monnitored regions: \(locationManager.monitoredRegions.count)")
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
        
        Timer.after(2) {
            // Check if there is any specificied region inside
            for i in self.regionStatus{
                if i.value == "inside" && i.key != "common"{
                    self.flag = false
                }
            }
            
            if self.flag == true && self.regionStatus[self.regionStatus.keys.filter({$0 == "common"}).first!] == "inside"{
                self.refreshStudents()
                Timer.after(5){
                    self.requestStateForMonitoredRegions()
                }
                log.debug("refreshHere")
            }
        }
    }
    
    @objc func takensuccess(region:CLBeaconRegion) {
        //if let index2 = GlobalData.monitoredRegions.index(of: region)
        /*GlobalData.monitoredRegions.remove(at: GlobalData.monitoredRegions.index(of: region)!)
         GlobalData.tempRegions.remove(at: GlobalData.tempRegions.index(of: region)!)
         locationManager.stopMonitoring(for: region)*/
        
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        log.info("Started monitoring \(region.identifier) region")
    }
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        
        log.info("Stop monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            log.debug("did exit region!!! \(region.identifier)")
            if region.identifier != "common"{
                if regionStatus[region.identifier] == "inside"{
                    regionStatus[region.identifier] = "outside"
                    GlobalData.regionExitFlag = true
                    self.requestStateForMonitoredRegions()
                }
            }else{
                regionStatus[region.identifier] = "outside"
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
        alamofire.loadStudentsAndStatus(lesson: GlobalData.currentLesson, lesson_date: lesson_date, returnString: "loadLateStudents")
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"loadLateStudents"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doneLoadingStudentsAndStatus), name: Notification.Name(rawValue: "loadLateStudents"), object: nil)
    }

    @objc func doneLoadingStudentsAndStatus(){
            self.getLateStudents()
    }

    private func getLateStudents() {
        if GlobalData.studentStatus.count > 0 {
            UserDefaults.standard.set(true, forKey: "background monitor")
            UserDefaults.standard.set(GlobalData.currentLesson.ldateid, forKey: "current lesson")
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
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        if GlobalData.lateStudents.count > 0{
            let newRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
            var count = 0
            locationManager.startMonitoring(for: newRegion)
            
            if (GlobalData.lateStudents.count % studentsLimit) > 0{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit) + 1
            }else{
                Constant.studentGroup = (GlobalData.lateStudents.count/studentsLimit)
            }
            
            Constant.currentGroup = 1
            for i in 0...GlobalData.lateStudents.count-1{
                if count < studentsLimit{
                    log.info("uuid: " + String(describing: uuid))
                    log.info("minor: " + String(describing: GlobalData.lateStudents[i].minor))
                    log.info("major: " + String(describing: GlobalData.lateStudents[i].major))
                    let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i].major!), minor: UInt16(GlobalData.lateStudents[i].minor!), identifier: String(GlobalData.lateStudents[i].student_id!))
                    if i<19{
                        locationManager.startMonitoring(for: newRegion)
                        GlobalData.regions.append(newRegion)
                    }
                }
                count += 1
            }
        }
       // endBackgroundTask()
    }
    
    private func refreshStudents(){
        log.info("Refreshing")
        log.info("Current group: \(Constant.currentGroup)")
        log.info("Total group: \(Constant.studentGroup)")
        self.stopMonitoring()
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
            for i in 0...(GlobalData.lateStudents.count - start) - 1{
                let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                locationManager.startMonitoring(for: newRegion)
                GlobalData.regions.append(newRegion)
            }
        }
        //locationManager.requestState(for: newRegion)
    }
    func takeAttendance() {
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        Constant.lecturer_id = UserDefaults.standard.integer(forKey: "id")
        
        let para1: Parameters = [
            "lesson_date_id": GlobalData.currentLesson.ldateid!,
            "student_id": Constant.identifier,
            "lecturer_id": Constant.lecturer_id,
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
                log.info("Attendance taken successful")
            }
            if let data = response.result.value{
                log.info("///////////////result below////////////")
                log.info(data)
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taken+\(Constant.identifier)"), object: nil)
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        log.info("application will resign active")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationWillEnterBackground(_ application: UIApplication) {
        log.info("will enter background")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        log.info("did enter background")
        registerBackgroundTask()
        checkTime()
    }
    
    func registerBackgroundTask() {
        log.info("registered backgroundTask")
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        log.info("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.stopMonitoring()
        NotificationCenter.default.post(name: Notification.Name(rawValue:"update time"), object: nil)
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

