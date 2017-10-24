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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var backgroundTask:UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var locationManager = CLLocationManager()
    let studentsLimit = 3
    var regionStatus = [String:String]()
    var flag = Bool()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        if UserDefaults.standard.string(forKey: "name") == nil{
            //No user logged in
        }else{
            //User logged in
            self.loadData()
            if let nowController = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "tab_bar_controller") as? UITabBarController{
                window?.rootViewController  = nowController
            }
        }
        self.stopMonitoring()
        return true
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            print("inside \(region.identifier)")
            regionStatus[region.identifier] = "inside"
            if region.identifier == "common"{
                
            }else{
                Constant.identifier = Int(region.identifier)!
                print("Entered specific")
                takeAttendance()
                NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"taken+\(Constant.identifier)"), object: nil)
                NotificationCenter.default.addObserver(self, selector: #selector(takensuccess(region:)), name: Notification.Name(rawValue: "taken+\(Constant.identifier)"), object: region)
                
            }
        case .outside:
            print("Outside bg \(region.identifier)")
            regionStatus[region.identifier] = "outside"
        case .unknown:
            print("UNKNOWN")
            
        }
    }
    
    private func checkTime(){
        
        if checkLesson.checkCurrentLesson() != false{
            
            //Currently has lesson
            loadLateStudents()
            
        }else if checkLesson.checkNextLesson() != false{
            
            //No lesson currently, show next lesson
            
        }else{
            
            //Today no lesson
            
        }
        
    }
    
    private func stopMonitoring(){
        for i in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: i)
        }
        
        print("stop monitoring")
        print(locationManager.monitoredRegions.count)
    }
    
    func requestStateForMonitoredRegions() {
        flag = true
        let monitoredRegions = Array(locationManager.monitoredRegions)
        
        // requestState for all regions
        for i in 0...locationManager.monitoredRegions.count - 1{
            locationManager.requestState(for: monitoredRegions[i])
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
                print("refreshHere")
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
        print("Started monitoring \(region.identifier) region")
    }
    func locationManager(_ manager: CLLocationManager, didStopMonitoringFor region: CLRegion) {
        
        print("Stop monitoring \(region.identifier) region")
        
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did exit region!!! \(region.identifier)")
            if region.identifier != "common"{
                if regionStatus[region.identifier] == "inside"{
                    regionStatus[region.identifier] = "outside"
                    GlobalData.regionExitFlag = true
                    self.requestStateForMonitoredRegions()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if (region is CLBeaconRegion) {
            print("did enter region!!! \(region.identifier)")
        }
        
    }
    func loadLateStudents() {
        GlobalData.lateStudents.removeAll()
        GlobalData.studentStatus.removeAll()
        let lesson_date = LessonDate()
        lesson_date.lesson_date = GlobalData.currentLesson.ldate
        lesson_date.lesson_date_id = GlobalData.currentLesson.ldateid
        lesson_date.lesson_id = GlobalData.currentLesson.lesson_id
        alamofire.loadStudentsAndStatus(lesson: GlobalData.currentLesson, lesson_date: lesson_date)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue:"done loading students and status"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(doneLoadingStudentsAndStatus), name: Notification.Name(rawValue: "done loading students and status"), object: nil)
    }

    @objc func doneLoadingStudentsAndStatus(){
            self.getLateStudents()
    }

    private func getLateStudents() {
        if GlobalData.studentStatus.count > 0 {
            for i in 0...GlobalData.studentStatus.count-1 {
                if(GlobalData.studentStatus[i].status == -1) {
                    GlobalData.lateStudents.append(GlobalData.students.filter({$0.student_id! == GlobalData.studentStatus[i].student_id!}).first!)
                }
            }
        }
        monitor()
    }
    
    func monitor() {
        
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        if GlobalData.lateStudents.count > 3{
            let newRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
            var count = 0
            locationManager.startMonitoring(for: newRegion)
            
            Constant.studentGroup = GlobalData.lateStudents.count/studentsLimit
            Constant.currentGroup = 1
            for i in 0...GlobalData.lateStudents.count-1{
                if count < studentsLimit{
                    print(uuid ?? "")
                    print(GlobalData.lateStudents[i].minor ?? "")
                    print(GlobalData.lateStudents[i].major ?? "")
                    let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i].major!), minor: UInt16(GlobalData.lateStudents[i].minor!), identifier: String(GlobalData.lateStudents[i].student_id!))
                    if i<19{
                        locationManager.startMonitoring(for: newRegion)
                        GlobalData.regions.append(newRegion)
                    }
                    locationManager.startMonitoring(for: newRegion)
                }
                count += 1
            }
        }
        
    }
    
    private func refreshStudents(){
        print("Refreshing")
        print("Current group \(Constant.currentGroup)")
        print(Constant.studentGroup)
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
        print("Next group \(Constant.currentGroup)")
        let uuid = NSUUID(uuidString: GlobalData.currentLesson.uuid!)as UUID?
        let start = (Constant.currentGroup - 1)*studentsLimit-1
        if (GlobalData.lateStudents.count - start) > studentsLimit-1 {
            for i in 0...studentsLimit-1{
                let newRegion = CLBeaconRegion(proximityUUID: uuid!, major:UInt16(GlobalData.lateStudents[i+start].major!), minor: UInt16(GlobalData.lateStudents[i+start].minor!), identifier: String(GlobalData.lateStudents[i+start].student_id!))
                locationManager.startMonitoring(for: newRegion)
                GlobalData.regions.append(newRegion)
            }
        }
        let newRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: "common")
        locationManager.startMonitoring(for: newRegion)
        //locationManager.requestState(for: newRegion)
    }
    func takeAttendance() {
        print(" bg Inside \(Constant.identifier)");
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        Constant.lecturer_id = UserDefaults.standard.integer(forKey: "lecturer_id")
        
        let para1: Parameters = [
            "lesson_date_id": GlobalData.currentLesson.ldateid!,
            "student_id": Constant.identifier,
            "lecturer_id": Constant.lecturer_id,
            ]
        let parameters: [String: Any] = ["data": [para1]]
        
        print(parameters)
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(Constant.URLCreateAtk, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            
            let statusCode = response.response?.statusCode
            if (statusCode == 200){
                print("Attendance taken successful")
            }
            if let data = response.result.value{
                print("///////////////result below////////////")
                print(data)
            }
            
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "taken+\(Constant.identifier)"), object: nil)
        
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("application will resign active")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    func applicationWillEnterBackground(_ application: UIApplication) {
        print("will!!!!1")
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("schculed timer")
        registerBackgroundTask()
        checkTime()
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
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
        print("application will terminate")
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

