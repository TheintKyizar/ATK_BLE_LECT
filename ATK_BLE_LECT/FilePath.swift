//
//  filePath.swift
//  ATK_BLE
//
//  Created by KyawLin on 7/14/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation
class filePath{
    
    static var timetablePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("timetable").path
    }
    
    static var weeklyTimetable: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("weeklyTimetable").path
    }

    static var studentPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("student" + GlobalData.lesson_id).path
    }
    
    static var lessonuuidPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("lessonuuid").path
    }
    
    static var historyPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("history" + GlobalData.ldate_id).path
    }
    
    static var historyDTPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("historyDT").path
    }
    
    static var tempStudents: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("tempStudents").path
    }
    
    static var offlineData: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("data").path
    }
}
