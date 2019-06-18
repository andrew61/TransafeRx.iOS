//
//  DateViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/8/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyDateViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
    var datePickerMode: UIDatePickerMode = .date
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            context.viewController(forKey: UITransitionContextViewControllerKey.from)
        }, completion: { context in
            self.tableView.reloadData()
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "datePickerCell", for: indexPath) as! DatePickerCell
        
        if self.survey.ListColor != nil {
            cell.datePicker.tintColor = UIColor(self.survey.ListColor!)
        }
        
        if self.survey.ListBackgroundColor != nil {
            cell.datePicker.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
            cell.contentView.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
            cell.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
        }
        
        cell.datePicker.datePickerMode = self.datePickerMode
        
        if self.question.Answer != nil {
            let dateFormatter = DateFormatter()
            
            switch self.datePickerMode {
            case .dateAndTime:
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .date:
                dateFormatter.dateFormat = "yyyy-MM-dd"
            default:
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }
            
            if let date = dateFormatter.date(from: self.question.Answer!.AnswerText!) {
                cell.datePicker.date = date
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? QuestionTableViewHeader ?? QuestionTableViewHeader(reuseIdentifier: "header")
        
        if self.questionImage != nil {
            header.questionImageView.image = self.questionImage!
            header.contentView.addConstraints(header.questionImageViewVerticalConstraints)
        }
        else {
            self.getImage(path: self.question.QuestionImage, completion: { (image) in
                if image != nil {
                    header.questionImageView.image = image
                    header.contentView.addConstraints(header.questionImageViewVerticalConstraints)
                    self.questionImage = image
                    self.tableView.reloadData()
                }
            })
        }
        
        header.questionLabel.text = self.question.QuestionText
        
        if self.survey.BodyColor != nil {
            header.questionLabel.textColor = UIColor(self.survey.BodyColor!)
        }
        
        header.questionLabel.font = UIFont.applicationFontFor(id: self.survey.BodyFontId, size: self.survey.BodyFontSize)
        
        return header
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? DatePickerCell {
            let dateFormatter = DateFormatter()
            
            switch self.datePickerMode {
            case .dateAndTime:
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            case .date:
                dateFormatter.dateFormat = "yyyy-MM-dd"
            default:
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            }
            
            self.answer.AnswerText = dateFormatter.string(from: cell.datePicker.date)
            self.answers.append(self.answer)
            super.getNextQuestion(sender)
        }
    }
}
