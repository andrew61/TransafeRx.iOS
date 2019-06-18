//
//  BloodPressureViewController.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class BloodPressureViewController: UIViewController{
    
    let titles = ["Get Data"]//["Read # of Data", "Read Times", "Read Results", "Take BP"]
    let timerDelay = 0.35

    var foraBpDevice: FORA_BP?
    var bpCount: Int?
    var bpValues = [BloodPressureMeasurement]()
    var bpDates = [Date]()
    var bpModel: String?
    var takingBp = false
    var readCharacteristics = false
    var clockWritten = false
    var clearingMemory = false

    @IBOutlet weak var pressureLabel: UILabel!
    
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

        let clearBarBtn = UIBarButtonItem(title: "Clear Memory", style: .plain, target: self, action: #selector(clearAction))
        parent?.navigationItem.rightBarButtonItem = clearBarBtn
        
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
    
    @objc func clearAction(){
        parent?.navigationItem.rightBarButtonItem?.isEnabled = false

        readCharacteristics = false
        clockWritten = false
        takingBp = false
        clearingMemory = true
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
        parent?.navigationItem.rightBarButtonItem?.isEnabled = false

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
    
    @objc func takeBP(){
        foraBpDevice?.foraBpTakeBPData()
    }
    
    @objc func turnOff(){
        parent?.navigationItem.rightBarButtonItem?.isEnabled = true
        foraBpDevice?.foraBpTurnOff()
        foraBpDevice?.connect(withTimeout: 30)
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
extension BloodPressureViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = titles[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
}

//MARK: -UITableViewDelegate
extension BloodPressureViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        foraBpDevice?.foraBpTakeBPData()
    }
}

//MARK: -ForaBpBluetoothDelegate
extension BloodPressureViewController: ForaBpBluetoothDelegate{
    
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
        parent?.navigationItem.rightBarButtonItem?.isEnabled = true
        self.dismissProgress()
    }
    
    func deviceDidFailToConnect() {
        print("deviceDidFailToConnect")
    }
    
    func deviceDidReadCharacteristics() {
        print("deviceDidReadCharacteristics")
        if !clockWritten{
            if clearingMemory{
                self.perform(#selector(self.clearData), with: nil, afterDelay: 3.0)
            }else{
                writeDeviceClock()
                clockWritten = true
            }
        }
    }
    
    func deviceDidClearData() {
        clearingMemory = false
        print("deviceDidClearData")
        self.perform(#selector(self.turnOff), with: nil, afterDelay: timerDelay)
    }
    
    func deviceDidStartBp() {
        print("deviceDidStartBp")
        takingBp = true
    }
    
    func deviceClockWritten() {
        print("deviceClockWritten")
        clockWritten = true
        self.perform(#selector(self.readDeviceModel), with: nil, afterDelay: timerDelay)
    }
    
    func gotDeviceModel(_ model: Any!) {
        if let model = model as? String{
            bpModel = model
        }
        self.perform(#selector(self.readStorageNumber), with: nil, afterDelay: timerDelay)
    }
    
    func gotDataCount(_ count: Any!) {
        print("Got Data Count: \(count)")
        if let count = count as? Int?{
            bpCount = count
            if bpCount! > 0{
                self.showProgress()
                self.perform(#selector(self.readStorageResult), with: nil, afterDelay: timerDelay)
            }else{
                self.perform(#selector(self.takeBP), with: nil, afterDelay: timerDelay)
            }
        }
    }
    
    func gotTimeResult(_ timeResult: Any!) {
        print("Got Time Result: \(timeResult)")
        if let date = timeResult as? Date{
            bpDates.append(date)
        }
        if bpDates.count < bpCount!{
            self.perform(#selector(self.readStorageTime), with: nil, afterDelay: timerDelay)
        }
        if bpDates.count == bpValues.count{
            print("GOT ALL VALUES")
            for i in (0..<bpDates.count){
                let measurement = bpValues[i];
                measurement.ReadingDate = bpDates[i];
                measurement.Model = bpModel
                ApiManager.sharedManager.saveBloodPressure(measurement, completion: { (error) in
                    if error != nil{
                        do{
                            try DBManager.sharedManager.insertBloodPressure(measurement)
                        }catch{
                            print(error)
                        }
                    }
                    if (self.bpDates.count - 1) == i{
                        print("SAVED ALL VALUES")
                        self.dismissProgress()
                        self.perform(#selector(self.takeBP), with: nil, afterDelay: self.timerDelay)
                    }
                })
            }
        }
    }
    
    func gotDataResult(_ dataResult: Any!) {
        print("Got Data Result: \(dataResult)")
        if let dataResult = dataResult as? BloodPressureMeasurement{
            bpValues.append(dataResult)
        }
        if bpValues.count < bpCount!{
            self.perform(#selector(self.readStorageResult), with: nil, afterDelay: timerDelay)
        }
        if bpValues.count == bpCount{
            self.perform(#selector(self.readStorageTime), with: nil, afterDelay: timerDelay)
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
            ApiManager.sharedManager.saveBloodPressure(reading, completion: { (error) in
                self.dismissProgress()
                if error != nil{
                    do{
                        try DBManager.sharedManager.insertBloodPressure(reading)
                    }catch{
                        print(error)
                    }
                    self.showErrorAlert()
                }
                self.perform(#selector(self.clearData), with: nil, afterDelay: 3.0)
            })
        }
    }
}
