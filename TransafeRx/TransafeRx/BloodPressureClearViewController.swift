//
//  BloodPressureClearViewController.swift
//  TransafeRx
//
//  Created by Tachl on 8/8/18.
//  Copyright © 2018 Tachl. All rights reserved.
//

import Foundation

class BloodPressureClearViewController: UIViewController{
    
    let titles = ["Get Data"]//["Read # of Data", "Read Times", "Read Results", "Take BP"]
    let timerDelay = 0.75
    
    var foraBpDevice: FORA_BP?
    var readCharacteristics = false
    var clockWritten = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foraBpDevice = FORA_BP(delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.title = "Blood Pressure"
        
        let connectBarBtn = UIBarButtonItem(title: "CONNECT", style: .plain, target: self, action: #selector(connectAction))
        parent?.navigationItem.rightBarButtonItem = connectBarBtn
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foraBpDevice?.connect(withTimeout: 30)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        foraBpDevice?.disconnect()
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @objc func connectAction(){
        readCharacteristics = false
        clockWritten = false
        foraBpDevice?.connect(withTimeout: 30)
    }
    
    func writeDeviceClock(){
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour, .minute])
        let dateComponents: DateComponents = calendar.dateComponents(unitFlags, from: Date())
        
        let yearStr = dateComponents.year!.description.substring(1)
        let year = Int(yearStr)
        
        foraBpDevice?.foraBpWriteClock(Int32(dateComponents.hour!), andMinute: Int32(dateComponents.minute!), andDay: Int32(dateComponents.day!), andMonth: Int32(dateComponents.month!), andYear: Int32(year!))
    }
    
    @objc func clearData(){
        foraBpDevice?.foraBpClearMemory()
    }
    
    @objc func turnOff(){
        foraBpDevice?.foraBpTurnOff()
    }
}

//MARK: -ForaBpBluetoothDelegate
extension BloodPressureClearViewController: ForaBpBluetoothDelegate{
    func gotDeviceModel(_ model: Any!) {
        
    }
    
    func gotReading(_ reading: Any!) {
        
    }
    
    func gotDataCount(_ count: Any!) {
        
    }
    
    func gotTimeResult(_ timeResult: Any!) {
        
    }
    
    func gotDataResult(_ dataResult: Any!) {
        
    }
    
    func deviceDidConnect() {
        readCharacteristics = false
        print("deviceDidConnect")
    }
    
    func deviceDidTimeout() {
        foraBpDevice?.connect(withTimeout: 30)
        print("deviceDidTimeout")
    }
    
    func deviceDidDisconnect() {
        print("deviceDidDisconnect")
        self.dismissProgress()
    }
    
    func deviceDidFailToConnect() {
        print("deviceDidFailToConnect")
    }
    
    func deviceDidReadCharacteristics() {
        print("deviceDidReadCharacteristics")
        if !clockWritten{
            writeDeviceClock()
            clockWritten = true
        }
    }
    
    func deviceDidClearData() {
        print("deviceDidClearData")
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(turnOff), userInfo: nil, repeats: false)
        
        let alertController = UIAlertController(title: "Device Data Cleared", message: "", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
    }
    
    func deviceDidStartBp() {
        print("deviceDidStartBp")
    }
    
    func deviceClockWritten() {
        print("deviceClockWritten")
        clockWritten = true
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(clearData), userInfo: nil, repeats: false)
    }
}
