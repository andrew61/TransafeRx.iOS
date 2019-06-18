//
//  MyInformationViewController.swift
//  TransafeRx
//
//  Created by Tachl on 9/1/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class MyInformationViewController: UIViewController{
    
    var phoneNumbers: PhoneNumbers?
    
    @IBOutlet weak var transplantBtn: UIButton!
    @IBOutlet weak var studyBtn: UIButton!
    @IBOutlet weak var pharmacyBtn: UIButton!
    @IBOutlet weak var refillBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.sharedManager.getPhoneNumbers { (numbers, error) in
            if error == nil{
                self.phoneNumbers = numbers
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "My Information"
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @IBAction func transplantAction(_ sender: UIButton) {
        guard let number = phoneNumbers?.Transplant else {
            guard let url = URL(string: "tel://8437925097") else {return}
            UIApplication.shared.openURL(url)
            return
        }
        guard let url = URL(string: "tel://\(number)") else {return}
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func studyAction(_ sender: UIButton) {
        guard let number = phoneNumbers?.Study else {
            guard let url = URL(string: "tel://8437927558") else {return}
            UIApplication.shared.openURL(url)
            return
        }
        guard let url = URL(string: "tel://\(number)") else {return}
        UIApplication.shared.openURL(url)
    }

    @IBAction func pharmacyAction(_ sender: UIButton) {
        guard let number = phoneNumbers?.Pharmacy else {
            guard let url = URL(string: "tel://8002370794") else {return}
            UIApplication.shared.openURL(url)
            return
        }
        guard let url = URL(string: "tel://\(number)") else {return}
        UIApplication.shared.openURL(url)
    }
    
    @IBAction func refillAction(_ sender: UIButton) {
        guard let number = phoneNumbers?.Refill else {
            guard let url = URL(string: "tel://8438761390") else {return}
            UIApplication.shared.openURL(url)
            return
        }
        guard let url = URL(string: "tel://\(number)") else {return}
        UIApplication.shared.openURL(url)
    }
}
