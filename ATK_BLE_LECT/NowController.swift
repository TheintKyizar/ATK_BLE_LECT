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
    
    @IBAction func beaconButton(_ sender: UIButton) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        locationManager.delegate = self
        bluetoothManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //broadcast()
        // Do any additional setup after loading the view.
        /* let bar = NSStatus.system()
         let length: CGFloat = -1
         var item = bar.statusItem(withLength: length)
         item?.button?.image = NS*/
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            uuid = UUID(uuidString: "00112233-4455-6677-8899-123456789012")as UUID?
            let beaconRegion = CLBeaconRegion(proximityUUID: uuid!, major: 100, minor: 2, identifier: "kyizar")
            dataDictionary = beaconRegion.peripheralData(withMeasuredPower: nil)
            //bluetoothManager = CBPeripheralManager.init(delegate: self, queue: nil)
            bluetoothManager.startAdvertising(dataDictionary as?[String: Any])
            print("broadcasting!!!!!!!!!!!! \(beaconRegion.identifier) + \(beaconRegion.proximityUUID) + \(String(describing: beaconRegion.major)) +\(String(describing: beaconRegion.minor))")
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
