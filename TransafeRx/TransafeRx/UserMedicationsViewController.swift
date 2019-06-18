//
//  UsermedicationsViewController.swift
//  TransafeRx
//
//  Created by Tachl on 7/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import UIKit
import DropDown

class UsermedicationsViewController: UIViewController{
    
    let dropDown = DropDown()
    
    var userMedications = [UserMedication]()
    var medicationsNotTakenBySection = [MedicationNotTakenGroup]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MedicationViewCell", bundle: nil), forCellReuseIdentifier: "MedicationViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ReachManager.shared.connectedToNetwork(){
            KVNProgress.show()
            ApiManager.sharedManager.getUserMedications { (userMedications, error) in
                KVNProgress.dismiss(completion: {
                    self.userMedications = userMedications
                    self.tableView.reloadData()
                })
            }
            ApiManager.sharedManager.getMedicationsNotTaken { (medications, error) in
                self.medicationsNotTakenBySection = MedicationNotTakenGroup().groupWithMedicationsBySection(medicationsNotTaken: medications)
            }
        }else{
            ReachManager.shared.showConnectionAlert(vc: self)
        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let takeAllBarBtn = UIBarButtonItem(title: "Take All", style: .plain, target: self, action: #selector(takeAllAction))
        parent?.navigationItem.rightBarButtonItems = [takeAllBarBtn]
        dropDown.anchorView = takeAllBarBtn
        dropDown.dataSource = ["Morning", "Noon", "Afternoon", "Evening"]
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.takeAllByGroup(index: index)
        }
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @objc func takeAllAction(){
        dropDown.show()
    }
    
    func takeAllByGroup(index: Int){
        var selectedGroup: MedicationNotTakenGroup?
        
        for group in medicationsNotTakenBySection{
            if group.section == index{
                selectedGroup = group
            }
        }
        
        if selectedGroup != nil{
            if !selectedGroup!.medications.isEmpty{
                let vc = MedicationTakenPopupController()
                vc.medications = selectedGroup!.medications
                vc.medicationsViewController = self
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
                vc.view.superview?.layer.cornerRadius = 5
                self.present(vc, animated: true, completion: nil)
            }else{
                emptyMedicationAlert()
            }
        }else{
            emptyMedicationAlert()
        }
    }
    
    func emptyMedicationAlert(){
        let alertController = UIAlertController(title: "No Medications", message: "", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func reloadData(){
        ApiManager.sharedManager.getMedicationsNotTaken { (medications, error) in
            self.medicationsNotTakenBySection = MedicationNotTakenGroup().groupWithMedicationsBySection(medicationsNotTaken: medications)
        }
    }
}

//MARK: - UITableViewDataSource
extension UsermedicationsViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userMedications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationViewCell", for: indexPath) as! MedicationViewCell
        let userMedication = userMedications[indexPath.row]
        
        cell.medicationLabel.text = userMedication.DrugName
        cell.instructionsLabel.text = userMedication.Instructions
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension UsermedicationsViewController: UITableViewDelegate{
    
}
