//
//  ViewController.swift
//  ForaBT
//
//  Created by Tachl on 7/19/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let titles = ["CONNECT A&D BP", "CONNECT FORA BP", "CONNECT FORA BG"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = titles[indexPath.row]
        
        return cell
    }
}

extension ViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            break
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "ForaBPViewController") as! ForaBPViewController
            show(vc, sender: self)
            break
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "ForaBGViewController") as! ForaBGViewController
            show(vc, sender: self)
            break
        default:break
        }
    }
}

