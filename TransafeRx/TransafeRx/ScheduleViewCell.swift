//
//  ScheduleViewCell.swift
//  TransafeRx
//
//  Created by Tachl on 8/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class ScheduleViewCell: UITableViewCell{
    
    var medicationNotTaken: MedicationNotTaken?
    var tableView: UITableView?
    var indexPath: IndexPath?
    
    @IBOutlet weak var medicationLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        checkboxImageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkAction(recognizer:)))
        self.addGestureRecognizer(tapGesture)
        //checkboxImageView.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if medicationNotTaken == nil{
            return
        }
        if medicationNotTaken!.isChecked{
            checkboxImageView.image = UIImage(named: "checkbox")
        }else{
            checkboxImageView.image = UIImage(named: "uncheckbox")
        }
    }
    
    @objc func checkAction(recognizer: UITapGestureRecognizer){
        if medicationNotTaken == nil{
            return
        }
        if medicationNotTaken!.isChecked{
            checkboxImageView.image = UIImage(named: "uncheckbox")
        }else{
            checkboxImageView.image = UIImage(named: "checkbox")
        }
        medicationNotTaken!.isChecked = !medicationNotTaken!.isChecked
        
        if tableView != nil && indexPath != nil{
            tableView!.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
}
