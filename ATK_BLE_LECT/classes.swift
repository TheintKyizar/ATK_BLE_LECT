//
//  Lesson.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import Foundation
import Alamofire
import UserNotifications

class Lesson : NSObject, NSCoding {
    
    var lesson_id: Int?
    var subject: String?
    var catalog: String?
    var venueName: String?
    var location: String?
    var class_section: String?
    var module_id:String?
    
    
    var ldate: String?
    var weekday: String?
    var ldateid: Int?
    
    var uuid: String?
    var major: UInt16?
    var minor: UInt16?
    
    var start_time: String?
    var end_time: String?
    
    
    var status: Int?
    var recorded_time: String?
    
    override init() {
        lesson_id = nil
        subject = "X"
        catalog = "X"
        ldate = "0/0/0"
        class_section = "P2J3"
        weekday = "0"
        ldateid = 0
        uuid = ""
        major = 0
        minor = 0
        start_time = "00:00"
        end_time = "00:00"
        status = nil
        recorded_time = "00:00"
        module_id = ""
    }
    
    required init(coder aDecoder: NSCoder) {
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as! Int?
        
        subject = aDecoder.decodeObject(forKey: "subject") as! String?
        catalog = aDecoder.decodeObject(forKey: "catalog") as! String?
        module_id = aDecoder.decodeObject(forKey: "module_id") as! String?
        
        venueName = aDecoder.decodeObject(forKey: "venueName") as! String?
        location = aDecoder.decodeObject(forKey: "location") as! String?
        class_section = aDecoder.decodeObject(forKey: "class_section") as! String?
        
        ldateid = aDecoder.decodeObject(forKey: "ldateid") as! Int?
        ldate = aDecoder.decodeObject(forKey: "ldate") as! String?
        weekday = aDecoder.decodeObject(forKey: "weekday") as! String?
        
        uuid = aDecoder.decodeObject(forKey: "uuid") as! String?
        major = aDecoder.decodeObject(forKey: "major") as! UInt16?
        minor = aDecoder.decodeObject(forKey: "minor") as! UInt16?
        
        start_time = aDecoder.decodeObject(forKey: "start_time") as! String?
        end_time = aDecoder.decodeObject(forKey: "end_time") as! String?
        
        status = aDecoder.decodeObject(forKey: "status") as! Int?
        recorded_time = aDecoder.decodeObject(forKey: "recorded_time") as! String?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(lesson_id, forKey: "lesson_id")
        
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(catalog, forKey: "catalog")
        aCoder.encode(module_id, forKey: "module_id")
        
        aCoder.encode(venueName, forKey: "venueName")
        
        aCoder.encode(location, forKey: "location")
        aCoder.encode(class_section, forKey: "class_section")
        
        aCoder.encode(ldateid, forKey: "ldateid")
        aCoder.encode(ldate, forKey: "ldate")
        aCoder.encode(weekday, forKey: "weekday")
        
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
        aCoder.encode(start_time, forKey: "start_time")
        aCoder.encode(end_time, forKey: "end_time")
        
        aCoder.encode(status, forKey: "status")
        aCoder.encode(recorded_time, forKey: "recorded_time")
        
    }
    
}

class Venue{
    
    var id = 0
    var location = ""
    var name = "room"
    var major:Int32 = 0
    var minor:Int32 = 0
}

class Student: NSObject, NSCoding{
    
    var student_card:String?
    var student_id:Int?
    var major:Int?
    var minor:Int?
    var name:String?
    
    override init(){
        student_card = ""
        student_id = 0
        major = 0
        minor = 0
        name = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        student_card = aDecoder.decodeObject(forKey: "card") as? String
        student_id = aDecoder.decodeObject(forKey: "id") as? Int
        major = aDecoder.decodeObject(forKey: "major") as? Int
        minor = aDecoder.decodeObject(forKey: "minor") as? Int
        name = aDecoder.decodeObject(forKey: "name") as? String
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(student_card, forKey: "card")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(student_id, forKey: "id")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
    }
}

class notification{
    static func notiContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        return content
    }
    static func addNotification(trigger: UNNotificationTrigger?, content:UNMutableNotificationContent, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {
            (error) in
            if error != nil {
                print("error adding notigicaion: \(error!.localizedDescription)")
            }
        }
    }
    
}

class checkLesson{
    
    static func checkCurrentLesson() -> Bool{
        let today = Date()
        let currentDateStr = format.formateDate(format: "yyyy-MM-dd", date: today)
        GlobalData.today = GlobalData.weeklyTimetable.filter({$0.ldate == currentDateStr})
        //check if today has lessons
        
        if GlobalData.today.count > 0{
            let currentTimeStr = format.formateDate(format: "HH:mm:ss", date: today)
            let currentLesson = GlobalData.today.first(where: {$0.start_time!<=currentTimeStr && $0.end_time!>=currentTimeStr})
            //check if current has lessons
            if currentLesson != nil{
                GlobalData.currentLesson = currentLesson!
                return true
            }else{
                GlobalData.currentLesson.ldateid = nil
                GlobalData.currentLesson = .init()
                return false
            }
            
        }else{
            GlobalData.currentLesson.ldateid = nil
            GlobalData.currentLesson = .init()
            return false
        }
    }
    
    static func checkNextLesson() -> Bool{
        let today = Date()
        let currentTimeStr = format.formateDate(format: "HH:mm:ss", date: today)
        if let nLesson = GlobalData.today.first(where: {$0.start_time!>currentTimeStr}){
            //estimate next lesson's time
            let time = nLesson.start_time?.components(separatedBy: ":")
            var hour:Int!
            var minute:Int!
            hour = Int((time?[0])!)
            minute = Int((time?[1])!)
            let totalSecond = hour*3600 + minute*60 - 300
            let hr = totalSecond/3600
            let min = (totalSecond%3600)/60
            GlobalData.nextLessonTime = "not yet time \ntry again after \(hr):\(min)"
            GlobalData.nextLesson = nLesson
            return true
        }else{
            GlobalData.nextLesson = .init()
            return false
        }
    }
    
}

class Status: NSObject,NSCoding{
    var recorded_time:String?
    var status:Int?
    var student_id:Int?
    override init(){
        recorded_time = " "
        status = -5
        student_id = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        recorded_time = aDecoder.decodeObject(forKey: "recorded_time") as? String
        status = aDecoder.decodeObject(forKey: "status") as? Int
        student_id = aDecoder.decodeObject(forKey: "student_id") as? Int
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(recorded_time, forKey: "recorded_time")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(student_id, forKey: "student_id")
        
    }
    
}

class LessonDate{
    var lesson_date_id:Int?
    var lesson_date:String?
    var lesson_id:Int?
}

class format{
    static func formatTime(format:String,time:String) -> Date{
        let dateFormattter = DateFormatter()
        dateFormattter.dateFormat = format
        return dateFormattter.date(from: time)!
    }
    static func formateDate(format:String,date:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}

class alamofire{
    
    static func loadStudents(lesson:Lesson){
        GlobalData.lesson_id = String(describing: lesson.lesson_id)
        print("Lesson_id : \(String(describing: lesson.lesson_id))")
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any]=[
            "lesson_id" : lesson.lesson_id!//13
        ]
        Alamofire.request(Constant.URLGetStudentOfLesson, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
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
                NotificationCenter.default.post(name: Notification.Name(rawValue: "done loading students"), object: nil)
            }
        }
    }
    
    static func loadStudentsAndStatus(lesson:Lesson, lesson_date:LessonDate, returnString:String){
        GlobalData.lesson_id = String(describing: lesson.lesson_id)
        print("Lesson_id : \(String(describing: lesson.lesson_id))")
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any]=[
            "lesson_id" : lesson.lesson_id!//13
        ]
        Alamofire.request(Constant.URLGetStudentOfLesson, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
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
                print(lesson_date.lesson_date_id ?? "")
                let parameters:[String:Any]=[
                    "lesson_date_id" : lesson_date.lesson_date_id!
                ]
                Alamofire.request(Constant.URLAtkStatus, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
                    if let JSON = response.result.value as? [[String:AnyObject]]{
                        GlobalData.studentStatus.removeAll()
                        for json in JSON{
                            let newStatus = Status()
                            newStatus.recorded_time = json["recorded_time"] as? String
                            newStatus.status = json["status"] as? Int
                            newStatus.student_id = json["student_id"] as? Int
                            GlobalData.studentStatus.append(newStatus)
                        }
                        print("done loading status")
                        NSKeyedArchiver.archiveRootObject(GlobalData.studentStatus, toFile: filePath.historyPath)
                        NotificationCenter.default.post(name: Notification.Name(rawValue: returnString), object: nil)
                    }
                }
            }
        }
    }
    
    static func updateStatus(lesson_date:LessonDate,student_id:Int,status:Int){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any] = [
            "lesson_date_id" : lesson_date.lesson_date_id!,
            "student_id" : student_id,
            "status" : status
        ]
        Alamofire.request(Constant.URLUpdateStatus, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if response.response?.statusCode == 200{
                NotificationCenter.default.post(name: Notification.Name(rawValue:"done updating status"), object: nil)
                log.info("done updating status")
            }
        }
        
    }
    
    static func loadWeeklyTimetable(){
        
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        Alamofire.request(Constant.URLWeeklyTimetable, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
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
                print("Done loading weeklyTimetable")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "done loading timetable"), object: nil)
                NSKeyedArchiver.archiveRootObject(GlobalData.weeklyTimetable, toFile: filePath.weeklyTimetable)
            }
        }
        
    }
    
    static func getStudentStatus(lesson:LessonDate){
        
        GlobalData.ldate_id = String(describing:lesson.lesson_date_id!)
        print(lesson.lesson_date_id ?? "")
        let token = UserDefaults.standard.string(forKey: "token")
        let headers:HTTPHeaders = [
            "Authorization" : "Bearer " + token!,
            "Content-Type" : "application/json"
        ]
        let parameters:[String:Any]=[
            "lesson_date_id" : lesson.lesson_date_id!
        ]
        Alamofire.request(Constant.URLAtkStatus, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [[String:AnyObject]]{
                GlobalData.studentStatus.removeAll()
                for json in JSON{
                    let newStatus = Status()
                    newStatus.recorded_time = json["recorded_time"] as? String
                    newStatus.status = json["status"] as? Int
                    newStatus.student_id = json["student_id"] as? Int
                    GlobalData.studentStatus.append(newStatus)
                }
                print("done loading status")
                NSKeyedArchiver.archiveRootObject(GlobalData.studentStatus, toFile: filePath.historyPath)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "done loading status"), object: nil)
            }
        }
        
    }
    
}
