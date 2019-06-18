//
//  MedicationTakenPopupController.swift
//  TransafeRx
//
//  Created by Tachl on 9/25/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import Eureka

class MedicationTakenPopupController: FormViewController{
    
    var medications = [MedicationNotTaken]()
    var schedulesViewController: SchedulesViewController?
    var medicationsViewController: UsermedicationsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Medications"
        
        // Enables the navigation accessory and stops navigation when a disabled row is encountered
        navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
        // Enables smooth scrolling on navigation to off-screen rows
        animateScroll = true
        // Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
        rowKeyboardSpacing = 20
        
        form +++ Section(){
            section in
        }
        
        for medication in medications{
            form.last! <<< LabelRow("Medication\(medication.ScheduleId)"){
                row in
                row.title = medication.DrugName
                row.cell.textLabel?.numberOfLines = 0
                let rowHeight = heightForView(text: row.title!, font: .boldSystemFont(ofSize: 17.0), width: view.bounds.width/2)
                row.cell.height = {rowHeight}
            }
        }
        
        form.last! <<< ButtonRow("SaveButton"){
            row in
            row.title = "Taken"
            row.onCellSelection({ (cell, row) in
                self.save()
            })
        }
    }
    
    func save(){
        let calendar = Calendar(identifier: .gregorian)
        var medicationActivity = [MedicationActivity]()
        
        for medication in medications{
            let scheduleDate = medication.ScheduleTime
            
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            var scheduleComponents = calendar.dateComponents([.hour, .minute], from: scheduleDate!)
            
            components.hour = scheduleComponents.hour
            components.minute = scheduleComponents.minute
            components.second = 0
            
            let date = calendar.date(from: components)!
            
            medicationActivity.append(MedicationActivity(activityTypeId: 1, userMedicationId: medication.UserMedicationId, scheduleId: medication.ScheduleId, scheduleDate: date))
        }
        
        if medicationActivity.isEmpty{
            return
        }
        KVNProgress.show()
        ApiManager.sharedManager.saveMedicationActivity(medicationActivity) { (error) in
            ApiManager.sharedManager.getMedicationsNotTaken { (medications, error) in
                KVNProgress.dismiss(completion: {
                    self.dismiss(animated: true, completion: nil)
                    if self.medicationsViewController != nil{
                        self.medicationsViewController!.reloadData()
                    }
                    if self.schedulesViewController != nil{
                        self.schedulesViewController!.reloadData()
                    }
                })
            }
        }
    }
}
