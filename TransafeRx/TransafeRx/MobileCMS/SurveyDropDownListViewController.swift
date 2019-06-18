//
//  DropDownViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/8/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyDropDownListViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.separatorStyle = .none
        self.tableView.backgroundColor = UIColor.clear
        
        if self.question.Options.count > 0 {
            self.selectedOption = self.question.Options[0]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.question.Answer != nil {
            let index = self.question.Options.index(where: { $0.OptionId == self.question.Answer!.OptionId })
            
            if index != nil {
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! PickerCell
                cell.pickerView.selectRow(index!, inComponent: 0, animated: true)
                self.pickerView(cell.pickerView, didSelectRow: index!, inComponent: 0)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickerCell", for: indexPath) as! PickerCell
        
        cell.pickerView.tintColor = UIColor(self.question.ListColor ?? "")
        cell.contentView.backgroundColor = UIColor(self.question.ListBackgroundColor ?? "")
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.withAlphaComponent(CGFloat(self.question.ListBackgroundAlpha ?? 1.0))
        cell.pickerView.backgroundColor = .clear
        cell.backgroundColor = .clear
        cell.pickerView.delegate = self
        cell.pickerView.dataSource = self
        
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
        
        header.questionLabel.attributedText = self.question.QuestionText?.htmlAttributedString(
            fontId: self.survey.BodyFontId,
            fontSize: self.survey.BodyFontSize,
            fontColor: self.survey.BodyColor)
        
        return header
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.question.Options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: self.question.Options[row].OptionText!, attributes: [NSAttributedString.Key.font: UIFont.applicationFontFor(id: self.survey.ListFontId, size: self.survey.ListFontSize), NSAttributedString.Key.foregroundColor: UIColor(self.survey.ListColor ?? "")])
        return attributedString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedOption = self.question.Options[row]
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answers.removeAll()
        
        let answer = SurveyAnswer()
        answer.OptionId = self.selectedOption?.OptionId
        self.answers.append(answer)
        super.getNextQuestion(sender)
    }
}
