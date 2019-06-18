//
//  HomeTabBarViewController.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class HomeTabBarViewController: UITabBarController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.setHidesBackButton(true, animated: false)
    }
}
