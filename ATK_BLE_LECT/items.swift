//
//  items.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import Foundation

class Constant{
    
    static let baseURL = "http://188.166.247.154/atk-ble/"
    static let URLLogin = baseURL + "api/web/index.php/v1/lecturer/login"
    static let URLLessonList = baseURL + "api/web/index.php/v1/lesson-lecturer?expand=lesson,venue,lesson_date,beacon_lesson"
    static let URLAllDateOfLesson = baseURL + "api/web/index.php/v1/lesson-date/search?lesson_id=1"
    static let URLAtkStatus = baseURL + "api/web/index.php/v1/attendance/list-attendance-status-by-lecturer"
    static let URLUpdateStatus = baseURL + "api/web/index.php/v1/attendance/update-status"
    static let URLGetStudentOfLesson = baseURL + "api/web/index.php/v1/timetable/get-student"
    static let URLCreateAtk = baseURL + "api/web/index.php/v1/beacon-attendance-lecturer/student-attendance"
    
    static var name = String()
    static var token = String()
    static var major = UInt16()
    static var minor = UInt16()
    static var device_hash = String()
    
}

class GlobalData{
    
    static var timetable = [Lesson]()
    
}
