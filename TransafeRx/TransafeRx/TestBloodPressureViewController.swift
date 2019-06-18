//
//  TestBloodPressureViewController.swift
//  TransafeRx
//
//  Created by Tachl on 4/20/18.
//  Copyright © 2018 Tachl. All rights reserved.
//

import Foundation

class TestBloodPressureViewController: UIViewController{
    let titles = ["Get Data"]//["Read # of Data", "Read Times", "Read Results", "Take BP"]
    let timerDelay = 0.5
    
    var foraBpDevice: FORA_BP?
    var bpCount: Int?
    var bpValues = [BloodPressureMeasurement]()
    var bpDates = [Date]()
    var dataValues = [String]()
    var bpModel: String?
    var takingBp = false
    var readCharacteristics = false
    var clockWritten = false
    
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foraBpDevice = FORA_BP(delegate: self)
        
        tableView.dataSource = self
        tableView.delegate = self
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
        takingBp = false
        foraBpDevice?.connect(withTimeout: 30)
    }
    
    @objc func readDeviceModel(){
        foraBpDevice?.foraBpReadModel()
    }
    
    @objc func readStorageNumber(){
        foraBpDevice?.foraBpReadStorageNumber()
    }
    
    @objc func readStorageResult(){
        foraBpDevice?.foraBpReadStorageResults(Int32(bpValues.count))
    }
    
    @objc func readStorageTime(){
        foraBpDevice?.foraBpReadStorageTime(Int32(bpDates.count))
    }
    
    func writeDeviceClock(){
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour, .minute])
        let dateComponents: DateComponents = calendar.dateComponents(unitFlags, from: Date())
        
        let yearStr = dateComponents.year!.description.substring(1)
        let year = Int(yearStr)
        
        foraBpDevice?.foraBpWriteClock(Int32(dateComponents.hour!), andMinute: Int32(dateComponents.minute!), andDay: Int32(dateComponents.day!), andMonth: Int32(dateComponents.month!), andYear: Int32(year!))
    }
    
    @objc func takeBP(){
        foraBpDevice?.foraBpTakeBPData()
    }
    
    @objc func turnOff(){
        foraBpDevice?.foraBpTurnOff()
    }
    
    func showErrorAlert(){
        let alertController = UIAlertController(title: "Error Saving Data", message: "Please Check Internet Connection", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { (action) in
        }
        alertController.addAction(dismissAction)
        present(alertController, animated: true, completion: nil)
    }
}
//MARK: -UITableViewDataSource
extension TestBloodPressureViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bpValues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let bpValue = bpValues[indexPath.row]
//        let bpDate = bpDates[indexPath.row]
//        let bpData = dataValues[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
//        let startIndex = bpData.index(bgData.startIndex, offsetBy: 4)
//        let endIndex = bpData.index(bgData.startIndex, offsetBy: 8)
//        let range = startIndex..<endIndex
//        cell.textLabel?.text = String(format: "Value: %@\nHexValue: %@\nRaw:%@", bgValue.description, bgData.substring(with: range), bgData)
        cell.textLabel?.text = bpValue.getMeasurement()
//        cell.detailTextLabel?.text = bgDate.dateTimeLocal
        
        return cell
    }
}

//MARK: -UITableViewDelegate
extension TestBloodPressureViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: -ForaBpBluetoothDelegate
extension TestBloodPressureViewController: ForaBpBluetoothDelegate{
    
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
    }
    
    func deviceDidStartBp() {
        print("deviceDidStartBp")
        takingBp = true
    }
    
    func deviceClockWritten() {
        print("deviceClockWritten")
        clockWritten = true
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readDeviceModel), userInfo: nil, repeats: false)
    }
    
    func gotDeviceModel(_ model: Any!) {
        if let model = model as? String{
            bpModel = model
        }
        let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageNumber), userInfo: nil, repeats: false)
    }
    
    func gotDataCount(_ count: Any!) {
        print("Got Data Count: \(count)")
        if let count = count as? Int?{
            bpCount = count
            if bpCount! > 0{
//                self.showProgress()
                let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageResult), userInfo: nil, repeats: false)
            }else{
                let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(takeBP), userInfo: nil, repeats: false)
            }
        }
    }
    
    func gotTimeResult(_ timeResult: Any!) {
        print("Got Time Result: \(timeResult)")
        if let date = timeResult as? Date{
            bpDates.append(date)
        }
        if bpDates.count < bpCount!{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageTime), userInfo: nil, repeats: false)
        }
        if bpDates.count == bpValues.count{
            for i in (0..<bpDates.count){
                let measurement = bpValues[i];
                measurement.ReadingDate = bpDates[i];
                measurement.Model = bpModel
                 if (self.bpDates.count - 1) == i{
                     let _ = Timer.scheduledTimer(timeInterval: self.timerDelay, target: self, selector: #selector(self.takeBP), userInfo: nil, repeats: false)
                    self.tableView.reloadData()
                    //show values in table
                }
            }
        }
    }
    
    func gotDataResult(_ dataResult: Any!) {
        print("Got Data Result: \(dataResult)")
        if let dataResult = dataResult as? BloodPressureMeasurement{
            bpValues.append(dataResult)
        }
        if bpValues.count < bpCount!{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageResult), userInfo: nil, repeats: false)
        }
        if bpValues.count == bpCount{
            let _ = Timer.scheduledTimer(timeInterval: timerDelay, target: self, selector: #selector(readStorageTime), userInfo: nil, repeats: false)
        }
    }
    
    func gotReading(_ reading: Any!) {
        print("Got Reading: \(reading)")
        if let reading = reading as? BloodPressureMeasurement{
            let bloodPressure = String(format: "%d/%d Pulse: %d", reading.Systolic!, reading.Diastolic!, reading.Pulse!)
            self.pressureLabel.text = String(format: "Blood Pressure Value: %@", bloodPressure)
            reading.Model = bpModel
            reading.ReadingDate = Date()
            reading.ReadingDateUTC = Date()

        }
    }
}
