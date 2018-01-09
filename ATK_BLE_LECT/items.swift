//
//  items.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import Foundation
import CoreLocation

class Constant{
    
    static let baseURL = "http://188.166.247.154/atk-ble/"
    static let URLLogin = baseURL + "api/web/index.php/v1/lecturer/login"
    static let URLLessonList = baseURL + "api/web/index.php/v1/lesson-lecturer?expand=lesson,venue,lesson_date,beacon_lesson"
    static let URLAllDateOfLesson = baseURL + "api/web/index.php/v1/lesson-date/search?lesson_id="
    static let URLAtkStatus = baseURL + "api/web/index.php/v1/attendance/list-attendance-status-by-lecturer"
    static let URLUpdateStatus = baseURL + "api/web/index.php/v1/attendance/update-status"
    static let URLGetStudentOfLesson = baseURL + "api/web/index.php/v1/timetable/get-student"
    static let URLCreateAtk = baseURL + "api/web/index.php/v1/beacon-attendance-lecturer/student-attendance"
    static let URLWeeklyTimetable = baseURL + "api/web/index.php/v1/lesson-lecturer/weekly-lesson?expand=lesson,venue,lesson_date_weekly,beacon_lesson"
    static let URLlessonUUID = baseURL + "api/web/index.php/v1/beacon-lesson/uuid"
    static let URLchangepass = baseURL + "api/web/index.php/v1/user/change-password"
    static let URLLogFile = baseURL + "/api/web/index.php/v1/site/upload"
    
    static var name = String()
    static var token = String()
    static var major = UInt16()
    static var minor = UInt16()
    static var device_hash = String()
    
    static var identifier = Int()
    static var student_id = Int()
    static var studentGroup = Int()
    static var currentGroup = Int()
    static var lecturer_id = Int()
    
}

class GlobalData{
    
    static var ldate_id = String()
    static var lesson_id = String()
    static var weeklyTimetable = [Lesson]()
    static var timetable = [Lesson]()
    static var today = [Lesson]()
    static var currentLesson = Lesson()
    static var nextLessonTime = String()
    static var nextLesson = Lesson()
    static var students = [Student]()
    static var studentStatus = [Status]()
    static var regionExitFlag = Bool()
    static var regions = [CLBeaconRegion]()
    static var lateStudents = [Student]()
    static var regionStatus = [String]()
    static var offlineData = [Attendance]()
    
    static let wdayStr = ["Monday", "Tuesday", "Wednesday", "Thursday" , "Friday", "Saturday"]
    static let wdayInt = ["2", "3", "4", "5", "6", "7"]
    static let wday:Dictionary = [
        "2" : "Monday",
        "3" : "Tuesday",
        "4" : "Wednesday",
        "5" : "Thursday",
        "6" : "Friday",
        "7" : "Saturday"
    ]
    
}
