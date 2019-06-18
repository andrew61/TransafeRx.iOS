//
//  TestBloodGlucoseViewController.swift
//  TransafeRx
//
//  Created by Tachl on 11/13/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation


class TestBloodGlucoseViewController: UIViewController{
    
    let timerDelay = 0.5
    
    var foraBgDevice: FORA_BG?
    var bgCount: Int?
    var bgValues = [NSNumber]()
    var dataValues = [String]()
    var bgDates = [Date]()
    var bgModel: String?
    var clockWritten = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Test BG"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 125
        
        foraBgDevice = FORA_BG(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.title = "Test BG"
        
        let connectBarBtn = UIBarButtonItem(title: "CONNECT", style: .plain, target: self, action: #selector(connectAction))
        parent?.navigationItem.rightBarButtonItem = connectBarBtn
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        foraBgDevice?.connect(withTimeout: 30)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        foraBgDevice?.disconnect()
        return
    }

    @objc func connectAction(){
        foraBgDevice?.connect(withTimeout: 30)
    }
    
    @objc func readDeviceModel(){
        foraBgDevice?.foraBgReadModel()
    }
    
    @objc func readStorageNumber(){
        foraBgDevice?.foraBgReadStorageNumber()
    }
    
    @objc func readStorageResult(){
        foraBgDevice?.foraBgReadStorageResults(Int32(bgValues.count))
    }
    
    @objc func readStorageTime(){
        foraBgDevice?.foraBgReadStorageTime(Int32(bgDates.count))
    }
    
    @objc func turnOff(){
        foraBgDevice?.foraBgTurnOff()
    }
    
    func writeDeviceClock(){
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour, .minute])
        let dateComponents: DateComponents = calendar.dateComponents(unitFlags, from: Date())
        
        let yearStr = dateComponents.year!.description.substring(1)
        let year = Int(yearStr)
        
        foraBgDevice?.foraBgWriteClock(Int32(dateComponents.hour!), andMinute: Int32(dateComponents.minute!), andDay: Int32(dateComponents.day!), andMonth: Int32(dateComponents.month!), andYear: Int32(year!))
    }

    func showErrorAlert(){
        let alertController = UIAlertController(title: "Error Saving Data", message: "Please Check Internet Connection", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { (action) in
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension TestBloodGlucoseViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bgValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let bgValue = bgValues[indexPath.row]
        let bgDate = bgDates[indexPath.row]
        let bgData = dataValues[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let startIndex = bgData.index(bgData.startIndex, offsetBy: 4)
        let endIndex = bgData.index(bgData.startIndex, offsetBy: 8)
        let range = startIndex..<endIndex
        cell.textLabel?.text = String(format: "Value: %@\nHexValue: %@\nRaw:%@", bgValue.description, bgData.substring(with: range), bgData)
        cell.detailTextLabel?.text = bgDate.dateTimeLocal
        
        return cell
    }
}

extension TestBloodGlucoseViewController: UITableViewDelegate{
    
    
}

//MARK: -ForaBgBluetoothDelegate
extension TestBloodGlucoseViewController: ForaBgBluetoothDelegate{
    
    func deviceDidClearData() {
        print("deviceDidClearData")
    }
    
    func deviceDidConnect() {
        print("deviceDidConnect")
    }
    
    func deviceDidTimeout() {
        foraBgDevice?.connect(withTimeout: 30)
        print("deviceDidTimeout")
    }
    
    func deviceDidDisconnect() {
        print("deviceDidDisconnect")
//        self.dismissProgress()
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
    
    func deviceDidTurnOff() {
        print("deviceDidTurnOff")
//        self.dismissProgress()
    }
    
    func deviceClockWritten() {
        print("deviceClockWritten")
        clockWritten = true
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readDeviceModel), userInfo: nil, repeats: false)
    }
    
    func gotDeviceModel(_ model: Any!) {
        if let model = model as? String{
            bgModel = model
        }
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageNumber), userInfo: nil, repeats: false)
    }
    
    func gotDataCount(_ count: Any!) {
        print("Got Data Count: \(count)")
        if let count = count as? Int?{
            bgCount = count
            if bgCount! > 0{
//                self.showProgress()
                let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageResult), userInfo: nil, repeats: false)
            }else{
                let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(turnOff), userInfo: nil, repeats: false)
                let alertController = UIAlertController(title: "No Data Available", message: "", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
                alertController.addAction(dismissAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func gotTimeResult(_ timeResult: Any!) {
        print("Got Time Result: \(timeResult)")
        if let date = timeResult as? Date{
            bgDates.append(date)
        }
        if bgDates.count < bgCount!{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageTime), userInfo: nil, repeats: false)
        }
        if bgDates.count == bgValues.count{
            self.tableView.reloadData()
//            self.dismissProgress()
        }
    }
    
    func gotDataResult(_ dataResult: Any!, andData data: Any!) {
        print("Got Data Result: \(dataResult)")
        if let value = dataResult as? NSNumber, let data = data as? String{
            bgValues.append(value)
            dataValues.append(data)
        }
        if bgValues.count < bgCount!{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageResult), userInfo: nil, repeats: false)
        }
        if bgValues.count == bgCount{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageTime), userInfo: nil, repeats: false)
        }
    }
    
    func gotReading(_ reading: Any!) {
        print("Got Reading: \(reading)")
    }
}
