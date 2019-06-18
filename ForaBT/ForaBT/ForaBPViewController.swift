//
//  ForaBPViewController.swift
//  ForaBT
//
//  Created by Tachl on 7/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import UIKit

class ForaBPViewController: UIViewController{
    
    let titles = ["Read Device", "Enter Comm", "Take BP", "Notify Char"]

    var foraBpDevice: FORA_BP?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.dataSource = self
        tableView.delegate = self
        foraBpDevice = FORA_BP(delegate: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        foraBpDevice?.connect(withTimeout: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        foraBpDevice?.disconnect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ForaBPViewController: CoreBluetoothDelegate{
    
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

extension ForaBPViewController: UITableViewDataSource{
    
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

extension ForaBPViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let readDeviceData = Data(bytes: Fora_TNG_BP_Commands().Command_ReadDevice, count: Fora_TNG_BP_Commands().Command_ReadDevice.count)
//        let enterCommData = Data(bytes: Fora_TNG_BP_Commands().Command_EnterCommunication, count: Fora_TNG_BP_Commands().Command_EnterCommunication.count)
//        let takeBPData = Data(bytes: Fora_TNG_BP_Commands().Command_StartBP, count: Fora_TNG_BP_Commands().Command_StartBP.count)
        switch(indexPath.row){
        case 0:
            foraBpDevice?.foraBpReadData()
            break
        case 1:
            foraBpDevice?.foraBpEnterCommData()
            break
        case 2:
            foraBpDevice?.foraBpTakeBPData()
            break
        case 3:
            foraBpDevice?.notifyCharactersitics()
            break
        default:break
        }
    }
}
