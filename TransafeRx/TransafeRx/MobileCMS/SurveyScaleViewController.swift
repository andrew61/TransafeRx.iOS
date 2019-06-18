//
//  ScaleViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/9/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyScaleViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
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
        
        self.selectedOption = self.options[0]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.question.Answer != nil {
            let index = self.options.index(where: { $0.OptionId == self.question.Answer!.OptionId })
            
            if index != nil {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ScaleCell
                cell.scaleSlider.value = Float(index!)
                self.scaleValueChanged(cell.scaleSlider)
            }
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "scaleCell", for: indexPath) as! ScaleCell
        
        if self.survey.ListColor != nil {
            cell.scaleLabel.textColor = UIColor(self.survey.ListColor!)
            cell.scaleSlider.thumbTintColor = UIColor(self.survey.ListColor!)
        }
        
        if self.survey.ListBackgroundColor != nil {
            cell.contentView.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
            cell.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
        }
        
        if self.survey.ProgressBarColor != nil {
            cell.scaleSlider.tintColor = UIColor(self.survey.ProgressBarColor!)
        }
        
        if self.survey.ProgressBarBackgroundColor != nil {
            cell.scaleSlider.backgroundColor = UIColor(self.survey.ProgressBarBackgroundColor!)
        }
        
        cell.scaleLabel.font = UIFont.applicationFontFor(id: self.survey.ListFontId, size: self.survey.ListFontSize)
        
        cell.scaleSlider.minimumValue = 0.0
        cell.scaleSlider.maximumValue = (Float(self.options.count) / 10) - 0.1
        
        cell.scaleLabel.text = self.options[0].OptionText
        
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
    
    @IBAction func scaleValueChanged(_ sender: AnyObject) {
        if let slider = sender as? UISlider {
            let value = Int(slider.value * 10)
            self.selectedOption = self.options[value]
            
            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ScaleCell {
                cell.scaleLabel.text = self.options[value].OptionText
            }
        }
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answer.OptionId = self.selectedOption.OptionId
        self.answers.append(self.answer)
        super.getNextQuestion(sender)
    }
}
