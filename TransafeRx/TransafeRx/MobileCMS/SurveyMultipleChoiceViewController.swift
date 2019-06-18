//
//  MultipleChoiceViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyMultipleChoiceViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
    var allowMultipleSelections: Bool = false
    var shouldAutoSubmit: Bool = true
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.allowsMultipleSelection = self.allowMultipleSelections
        self.tableView.separatorColor = UIColor(self.question.SeparatorColor ?? "#aaaaaa")
        self.tableView.backgroundColor = UIColor.clear
        
        if self.question.Required || (self.survey.AutoSubmit && !self.allowMultipleSelections && self.question.Answers.isEmpty) {
            self.nextButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.question.Answers.isEmpty {
            self.shouldAutoSubmit = false
            for answer in self.question.Answers {
                let index = self.question.Options.index(where: { $0.OptionId == answer.OptionId })
                
                if index != nil {
                    let indexPath = IndexPath(row: index!, section: 0)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                    self.tableView(self.tableView, didSelectRowAt: indexPath)
                }
            }
            self.shouldAutoSubmit = true
            self.nextButton.isEnabled = true
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
    
    func updateCell(cell: MultipleChoiceCell, selected: Bool) {
        if selected {
            cell.choiceImage.isHidden = false
            cell.choiceImage.tintColor = UIColor(self.question.SelectedIconColor ?? "")
            cell.choiceLabel.textColor = UIColor(self.question.SelectedColor ?? "")
            cell.choiceLabel.font = UIFont.applicationFontFor(id: self.question.SelectedFontId, size: self.question.SelectedFontSize)
            cell.contentView.backgroundColor = UIColor(self.question.SelectedBackgroundColor ?? "")
            cell.contentView.backgroundColor = cell.contentView.backgroundColor?.withAlphaComponent(CGFloat(self.question.SelectedBackgroundAlpha ?? 1.0))
        }
        else {
            cell.choiceImage.isHidden = true
            cell.choiceLabel.textColor = UIColor(self.question.ListColor ?? "")
            cell.choiceLabel.font = UIFont.applicationFontFor(id: self.question.ListFontId, size: self.question.ListFontSize)
            cell.contentView.backgroundColor = UIColor(self.question.ListBackgroundColor ?? "")
            cell.contentView.backgroundColor = cell.contentView.backgroundColor?.withAlphaComponent(CGFloat(self.question.ListBackgroundAlpha ?? 1.0))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.question.Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "multipleChoiceCell", for: indexPath) as! MultipleChoiceCell
        let option = self.question.Options[indexPath.row]
        
        cell.choiceLabel.text = option.OptionText
        
        if option == self.selectedOption || self.selectedOptions.contains(option) {
            self.updateCell(cell: cell, selected: true)
        }
        else {
            self.updateCell(cell: cell, selected: false)
        }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? MultipleChoiceCell {
            let option = self.question.Options[indexPath.row]
            
            if self.allowMultipleSelections {
                self.selectedOptions.insert(option)
            }
            else {
                self.selectedOption = option
            }
            
            self.updateCell(cell: cell, selected: true)
            
            if self.survey.AutoSubmit && !self.allowMultipleSelections && !self.didGoBack && self.shouldAutoSubmit {
                self.getNextQuestion(self)
            }
            
            self.didGoBack = false
            self.nextButton.isEnabled = true
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? MultipleChoiceCell {
            let option = self.question.Options[indexPath.row]
            
            if self.allowMultipleSelections {
                if self.selectedOptions.contains(option) {
                    self.selectedOptions.remove(option)
                }
                
                if self.question.Required && self.selectedOptions.isEmpty {
                    self.nextButton.isEnabled = false
                }
            }
            else {
                self.selectedOption = SurveyQuestionOption()
            }
            
            self.updateCell(cell: cell, selected: false)
        }
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answers.removeAll()
        
        if self.allowMultipleSelections {
            let date = Date()
            for option in self.selectedOptions {
                let answer = SurveyAnswer()
                answer.OptionId = option.OptionId
                answer.AnswerDateUTC = date
                answer.AnswerDateDTO = date
                self.answers.append(answer)
            }
        }
        else {
            let answer = SurveyAnswer()
            answer.OptionId = self.selectedOption?.OptionId
            self.answers.append(answer)
        }
        
        if self.answers.isEmpty {
            self.answers.append(SurveyAnswer())
        }
        
        super.getNextQuestion(sender)
    }
}
