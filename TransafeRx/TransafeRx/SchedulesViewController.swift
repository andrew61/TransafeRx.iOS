//
//  SchedulesViewController.swift
//  TransafeRx
//
//  Created by Tachl on 8/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import DropDown

class SchedulesViewController: UIViewController{
    
    let dropDown = DropDown()

    var medicationsNotTaken = [MedicationNotTakenGroup]()
    var medicationsNotTakenBySection = [MedicationNotTakenGroup]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ScheduleViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 71.0
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if ReachManager.shared.connectedToNetwork(){
            KVNProgress.show()
            ApiManager.sharedManager.getMedicationsNotTaken { (medications, error) in
                KVNProgress.dismiss(completion: {
                    self.medicationsNotTaken = MedicationNotTakenGroup().groupWithMedications(medicationsNotTaken: medications)
                    self.medicationsNotTakenBySection = MedicationNotTakenGroup().groupWithMedicationsBySection(medicationsNotTaken: medications)
                    self.tableView.reloadData()
                })
            }
        }else{
            ReachManager.shared.showConnectionAlert(vc: self)
        }
        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let takeBarBtn = UIBarButtonItem(title: "Take Selected", style: .plain, target: self, action: #selector(takeAction))
        let takeAllBarBtn = UIBarButtonItem(title: "Take All or", style: .plain, target: self, action: #selector(takeAllAction))
        parent?.navigationItem.rightBarButtonItems = [takeBarBtn, takeAllBarBtn]
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
    
    @objc func takeAction(){
        var medications = [MedicationNotTaken]()
        
        for group in medicationsNotTaken{
            for medication in group.medications{
                if medication.isChecked{
                    medications.append(medication)
                }
            }
        }

        if medications.isEmpty{
            emptyMedicationAlert()
        }else{
            let vc = MedicationTakenPopupController()
            vc.medications = medications
            vc.schedulesViewController = self
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
            vc.view.superview?.layer.cornerRadius = 5
            self.present(vc, animated: true, completion: nil)
        }
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
                vc.schedulesViewController = self
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
            self.medicationsNotTaken = MedicationNotTakenGroup().groupWithMedications(medicationsNotTaken: medications)
            self.medicationsNotTakenBySection = MedicationNotTakenGroup().groupWithMedicationsBySection(medicationsNotTaken: medications)
            self.tableView.reloadData()
        }
    }
}

//MARK: - UITableViewDataSource
extension SchedulesViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return medicationsNotTaken.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationsNotTaken[section].medications.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var labelHeader: UILabel?
        
        let medicationNotTakenGroup = medicationsNotTaken[section]
        
        labelHeader = UILabel(frame: CGRect(x: 50, y: 0, width: 50, height: 32))
        labelHeader?.text = medicationNotTakenGroup.getGroupTime()
        labelHeader?.font = .boldSystemFont(ofSize: 18.0)//UIFont(name: "Helvetica", size: 22.0)
        
        return labelHeader
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleViewCell", for: indexPath) as! ScheduleViewCell
        
        let medicationNotTaken = medicationsNotTaken[indexPath.section].medications[indexPath.row]
        
        cell.tableView = tableView
        cell.indexPath = indexPath
        cell.medicationNotTaken = medicationNotTaken
        cell.medicationLabel.text = medicationNotTaken.DrugName
        cell.instructionsLabel.text = medicationNotTaken.Instructions
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let medicationNotTaken = medicationsNotTaken[indexPath.section].medications[indexPath.row]
        
        var height: CGFloat = 50.0
        var brandHeight: CGFloat = 0.0
        var instructionHeight: CGFloat = 0.0
        
        if medicationNotTaken.DrugName != nil{
            brandHeight = heightForView(text: medicationNotTaken.DrugName!, font: .boldSystemFont(ofSize: 17.0), width: view.bounds.width - 50)
        }
        if medicationNotTaken.Instructions != nil{
            instructionHeight = heightForView(text: medicationNotTaken.Instructions!, font: .systemFont(ofSize: 17.0), width: view.bounds.width - 50)
        }
        
        height += (brandHeight + instructionHeight)

        if medicationNotTaken.isChecked{
            height += 25.0
        }
        
        return height
    }
}

//MARK: - UITableViewDelegate
extension SchedulesViewController: UITableViewDelegate{
    
}
