//
//  filePath.swift
//  ATK_BLE
//
//  Created by KyawLin on 7/14/17.
//  Copyright © 2017 beacon. All rights reserved.
//

import Foundation
struct filePath{
    static var timetablePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("timetable").path
    }
    
    static var classmatePath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("classmate").path
    }
    
    static var lecturerPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("lecturer").path
    }
    
    static var lessonuuidPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("lessonuuid").path
    }
    
    static var historyPath: String{
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        return url!.appendingPathComponent("history").path
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
}
