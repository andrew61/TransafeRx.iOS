//
//  MedicationNotTakenGroup.swift
//  TransafeRx
//
//  Created by Tachl on 9/13/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class MedicationNotTakenGroup: NSObject{
    
    let calendar = Calendar(identifier: .gregorian)

    var medications = [MedicationNotTaken]()
    var section: Int?
    
    func groupWithMedicationsBySection(medicationsNotTaken: [MedicationNotTaken]) -> [MedicationNotTakenGroup]{
        var groups = [MedicationNotTakenGroup]()
        
        var distinctGroups = Set<Int>()
        //GROUPS: 2AM - 9AM; 10AM - 1PM; 2PM - 5PM; 6PM - 1AM
        
        for medicationNotTaken in medicationsNotTaken{
            if medicationNotTaken.ScheduleTime != nil{
                var dateComp = calendar.dateComponents([.hour], from: medicationNotTaken.ScheduleTime!)
                if dateComp.hour! >= 2 && dateComp.hour! <= 9{
                    distinctGroups.insert(0)
                }else if dateComp.hour! >= 10 && dateComp.hour! <= 13{
                    distinctGroups.insert(1)
                }else if dateComp.hour! >= 14 && dateComp.hour! <= 17{
                    distinctGroups.insert(2)
                }else if (dateComp.hour! >= 18 && dateComp.hour! <= 24) || dateComp.hour! == 1{
                    distinctGroups.insert(3)
                }
            }
        }
        
        for group in distinctGroups{
            var filteredMedications = [MedicationNotTaken]()
            
            for medicationNotTaken in medicationsNotTaken{
                var dateComp = calendar.dateComponents([.hour], from: medicationNotTaken.ScheduleTime!)
                if dateComp.hour! >= 2 && dateComp.hour! <= 9{
                    if group == 0{
                        filteredMedications.append(medicationNotTaken)
                    }
                }else if dateComp.hour! >= 10 && dateComp.hour! <= 13{
                    if group == 1{
                        filteredMedications.append(medicationNotTaken)
                    }
                }else if dateComp.hour! >= 14 && dateComp.hour! <= 17{
                    if group == 2{
                        filteredMedications.append(medicationNotTaken)
                    }
                }else if (dateComp.hour! >= 18 && dateComp.hour! <= 24) || dateComp.hour! == 1{
                    if group == 3{
                        filteredMedications.append(medicationNotTaken)
                    }
                }
            }
            
            if !filteredMedications.isEmpty{
                let medicationGroup = MedicationNotTakenGroup()
                medicationGroup.medications = filteredMedications
                medicationGroup.section = group
                groups.append(medicationGroup)
            }
        }
        
        return groups.sorted(by: {$0.section! < $1.section!})
    }
    
    func groupWithMedications(medicationsNotTaken: [MedicationNotTaken]) -> [MedicationNotTakenGroup]{
        var groups = [MedicationNotTakenGroup]()
        
        var distinctGroups = Set<Int>()
        
        for medicationNotTaken in medicationsNotTaken{
            if medicationNotTaken.ScheduleTime != nil{
                var dateComp = calendar.dateComponents([.hour], from: medicationNotTaken.ScheduleTime!)
                distinctGroups.insert(dateComp.hour!)
            }
        }
        
        for group in distinctGroups{
            var filteredMedications = [MedicationNotTaken]()
            
            for medicationNotTaken in medicationsNotTaken{
                var dateComp = calendar.dateComponents([.hour], from: medicationNotTaken.ScheduleTime!)
                if dateComp.hour! == group{
                    filteredMedications.append(medicationNotTaken)
                }
            }
            
            if !filteredMedications.isEmpty{
                let medicationGroup = MedicationNotTakenGroup()
                medicationGroup.medications = filteredMedications
                medicationGroup.section = group
                groups.append(medicationGroup)
            }
        }
        
        return groups.sorted(by: {$0.section! < $1.section!})
    }
    
    func getGroupTime() -> String?{
        var groupTime: String?
        
        if !self.medications.isEmpty{
            if self.medications.first?.ScheduleTime?.time != nil{
                groupTime = String(format: "    %@", self.medications.first!.ScheduleTime!.time)
            }
        }
        
        return groupTime
    }
}
