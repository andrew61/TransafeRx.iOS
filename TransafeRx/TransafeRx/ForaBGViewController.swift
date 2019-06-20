//
//  ForaBGViewController.swift
//  ForaBT
//
//  Created by Tachl on 7/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import UIKit

class ForaBGViewController: UIViewController{
    
    let titles = ["Turn Off Device", "Write Device Clock", "Read Device Clock", "Read Device Model", "Read Storage Part 1 (time)", "Read Storage Part 2 (result)", "Read Storage Number of Data", "Notify Characteristics", "Clear Memory"]
    
    var foraBgDevice: FORA_BG?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        foraBgDevice = FORA_BG(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        foraBgDevice?.connect(withTimeout: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        foraBgDevice?.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ForaBGViewController: CoreBluetoothDelegate{
    
    func deviceDidConnect() {
        print("deviceDidConnect")
    }
    
    func deviceDidTimeout() {
        print("deviceDidTimeout")
    }
    
    func deviceDidDisconnect() {
        print("deviceDidDisconnect")
    }
    
    func deviceDidFailToConnect() {
        print("deviceDidFailToConnect")
    }
    
    func gotReading(_ reading: Any!) {
        print("Got Reading: \(reading)")
    }
}

extension ForaBGViewController: UITableViewDataSource{
    
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

extension ForaBGViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0://turn off device
            foraBgDevice?.foraBgTurnOff()
            break
        case 1://Write Device Clock
            break
        case 2://Read Device Clock
            foraBgDevice?.foraBgReadClock()
            break
        case 3://Read Device Model
            foraBgDevice?.foraBgReadModel()
            break
        case 4://Read Storage Part 1 (time)
            foraBgDevice?.foraBgReadStorageTime()
            break
        case 5://Read Storage Part 2 (result)
            foraBgDevice?.foraBgReadStorageResults()
            break
        case 6://Read Storage Number of Data
            foraBgDevice?.foraBgReadStoageNumber()
            break
        case 7:
            foraBgDevice?.notifyCharactersitics()
            break
        case 8:
            //foraBgDevice?.foraBgClearMemory()
            break
        default:break
        }
    }
}
