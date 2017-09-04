//
//  Lesson.swift
//  ATK_BLE_LECT
//
//  Created by KyawLin on 9/4/17.
//  Copyright © 2017 Kyi Zar Theint. All rights reserved.
//

import Foundation

class Lesson : NSObject, NSCoding {
    
    var lesson_id: Int?
    var subject: String?
    var catalog: String?
    var venueName: String?
    var location: String?
    var class_section: String?
    
    
    var ldate: String?
    var weekday: String?
    var ldateid: Int?
    
    var major: UInt16?
    var minor: UInt16?
    
    var start_time: String?
    var end_time: String?
    
    
    var status: Int?
    var recorded_time: String?
    
    override init() {
        lesson_id = 0
        subject = "X"
        catalog = "X"
        ldate = "0/0/0"
        class_section = "P2J3"
        weekday = "0"
        ldateid = 0
        major = 0
        minor = 0
        start_time = "00:00"
        end_time = "00:00"
        status = nil
        recorded_time = "00:00"
    }
    
    required init(coder aDecoder: NSCoder) {
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as! Int?
        
        subject = aDecoder.decodeObject(forKey: "subject") as! String?
        catalog = aDecoder.decodeObject(forKey: "catalog") as! String?
        
        venueName = aDecoder.decodeObject(forKey: "venueName") as! String?
        location = aDecoder.decodeObject(forKey: "location") as! String?
        class_section = aDecoder.decodeObject(forKey: "class_section") as! String?
        
        ldateid = aDecoder.decodeObject(forKey: "ldateid") as! Int?
        ldate = aDecoder.decodeObject(forKey: "ldate") as! String?
        weekday = aDecoder.decodeObject(forKey: "weekday") as! String?
        
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
        
        aCoder.encode(venueName, forKey: "venueName")
        
        aCoder.encode(location, forKey: "location")
        aCoder.encode(class_section, forKey: "class_section")
        
        aCoder.encode(ldateid, forKey: "ldateid")
        aCoder.encode(ldate, forKey: "ldate")
        aCoder.encode(weekday, forKey: "weekday")
        
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
    
    var lesson_id:Int?
    var student_id:[Int]?
    var major:[Int]?
    var minor:[Int]?
    
    override init(){
        lesson_id = 0
        student_id = []
        major = []
        minor = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        lesson_id = aDecoder.decodeObject(forKey: "lesson_id") as? Int
        student_id = aDecoder.decodeObject(forKey: "id") as? [Int]
        major = aDecoder.decodeObject(forKey: "major") as? [Int]
        minor = aDecoder.decodeObject(forKey: "minor") as? [Int]
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(lesson_id, forKey: "lesson_id")
        aCoder.encode(student_id, forKey: "id")
        aCoder.encode(major, forKey: "major")
        aCoder.encode(minor, forKey: "minor")
        
    }
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
