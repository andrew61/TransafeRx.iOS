//
//  BloodGlucoseViewController.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import ExternalAccessory
import AVFoundation

class BloodGlucoseViewController: UIViewController{
    
    let titles = ["Get Data"]//["Read # of Data", "Read Times", "Read Results", "Read Last Result"]
    let timerDelay = 0.5

    var foraBgDevice: FORA_BG?
    var bgCount: Int?
    var bgValues = [NSNumber]()
    var bgDates = [Date]()
    var bgModel: String?
    var clockWritten = false
    
    @IBOutlet weak var glucoseLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foraBgDevice = FORA_BG(delegate: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.title = "Blood Glucose"
        
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
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @objc func connectAction(){
        clockWritten = false
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
    
    @objc func clearDeviceMemory(){
        foraBgDevice?.foraBgClearMemory()
    }
    
    func writeDeviceClock(){
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.day, .month, .year, .hour, .minute])
        let dateComponents: DateComponents = calendar.dateComponents(unitFlags, from: Date())
        
        let yearStr = dateComponents.year!.description.substring(1)
        let year = Int(yearStr)
   
        foraBgDevice?.foraBgWriteClock(Int32(dateComponents.hour!), andMinute: Int32(dateComponents.minute!), andDay: Int32(dateComponents.day!), andMonth: Int32(dateComponents.month!), andYear: Int32(year!))
    }
    
    @objc func turnOff(){
        foraBgDevice?.foraBgTurnOff()
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
extension BloodGlucoseViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = titles[indexPath.row]
        
        return cell
    }
}

//MARK: -UITableViewDelegate
extension BloodGlucoseViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: -ForaBgBluetoothDelegate
extension BloodGlucoseViewController: ForaBgBluetoothDelegate{

    func deviceDidConnect() {
        print("deviceDidConnect")
    }
    
    func deviceDidTimeout() {
        foraBgDevice?.connect(withTimeout: 30)
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
        self.dismissProgress()
    }
    
    func deviceDidTurnOff() {
        print("deviceDidTurnOff")
        self.dismissProgress()
    }
    
    func deviceClockWritten() {
        print("deviceClockWritten")
        clockWritten = true
        self.perform(#selector(readDeviceModel), with: nil, afterDelay: timerDelay)
    }
    
    func gotDeviceModel(_ model: Any!) {
        if let model = model as? String{
            bgModel = model
        }
        self.perform(#selector(readStorageNumber), with: nil, afterDelay: timerDelay)
    }
    
    func gotDataCount(_ count: Any!) {
        print("Got Data Count: \(count)")
        if let count = count as? Int?{
            bgCount = count
            if bgCount! > 0{
                self.showProgress()
                self.perform(#selector(readStorageResult), with: nil, afterDelay: timerDelay)
            }else{
                self.perform(#selector(turnOff), with: nil, afterDelay: timerDelay)
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
            self.perform(#selector(readStorageTime), with: nil, afterDelay: timerDelay)
        }
        if bgDates.count == bgValues.count{
            for i in (0..<bgDates.count){
                let reading = BloodGlucoseMeasurement(glucoseLevel: bgValues[i].intValue, readingDate: bgDates[i], model: bgModel)
                ApiManager.sharedManager.saveBloodGlucose(reading, completion: { (error) in
                    if error != nil{
                        do{
                            try DBManager.sharedManager.insertBloodGlucose(reading)
                        }catch{
                            print(error)
                        }
                        if (self.bgDates.count - 1) == i{
                            self.dismissProgress()
                            self.showErrorAlert()
                        }
                    }
                    if (self.bgDates.count - 1) == i{
                        self.glucoseLabel.text = String(format: "Blood Glucose Value: %d", self.bgValues[0].intValue)
                        self.perform(#selector(self.clearDeviceMemory), with: nil, afterDelay: 3.0)
                    }
                })
            }
        }
    }
    
    func gotDataResult(_ dataResult: Any!, andData data: Any!) {
        print("Got Data Result: \(dataResult)")
        if let value = dataResult as? NSNumber{
            bgValues.append(value)
        }
        if bgValues.count < bgCount!{
            self.perform(#selector(self.readStorageResult), with: nil, afterDelay: timerDelay)
        }
        if bgValues.count == bgCount{
            self.perform(#selector(self.readStorageTime), with: nil, afterDelay: timerDelay)
        }
    }
    
    func gotReading(_ reading: Any!) {
        print("Got Reading: \(reading)")
    }
}
