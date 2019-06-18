//
//  CategoryViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/9/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyCategoryListViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
    var categories = [(SurveyQuestionCategory, Array<SurveyQuestionOption>)]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.question.Required {
            self.nextButton.isEnabled = false
        }
        
        self.categories = SurveyQuestionCategory.groupsWith(options: self.question.Options)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.separatorColor = UIColor(self.question.SeparatorColor ?? "#aaaaaa")
        self.tableView.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for answer in self.question.Answers {
            let index = self.categories.index(where: { $0.0.CategoryId == answer.CategoryId })
            
            if index != nil {
                let cell = self.tableView.cellForRow(at: IndexPath(row: index!, section: 0)) as! CategoryCell
                let option = self.categories[index!].1.first(where: { $0.OptionId == answer.OptionId })
                
                if option != nil {
                    cell.optionLabel.text = option?.OptionText
                    self.categories[index!].0.SelectedOption = option
                }
                
                self.nextButton.isEnabled = true
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
        return self.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        let category = self.categories[indexPath.row]
        
        cell.categoryLabel.text = category.0.Name
        cell.optionLabel.text = category.0.SelectedOption?.OptionText
        cell.categoryLabel.textColor = UIColor(self.question.ListColor ?? "")
        cell.optionLabel.textColor = UIColor(self.question.ListColor ?? "")
        cell.contentView.backgroundColor = UIColor(self.question.ListBackgroundColor ?? "")
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.withAlphaComponent(CGFloat(self.question.ListBackgroundAlpha ?? 1.0))
        cell.categoryLabel.font = UIFont.applicationFontFor(id: self.question.ListFontId, size: self.question.ListFontSize)
        cell.optionLabel.font = UIFont.applicationFontFor(id: self.question.ListFontId, size: self.question.ListFontSize)
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = self.tableView.cellForRow(at: indexPath) as? CategoryCell {
            let category = self.categories[indexPath.row]
            let optionSheet = UIAlertController(title: category.0.Name, message: "Choose an Option", preferredStyle: .actionSheet)
            
            for option in category.1 {
                let action = UIAlertAction(title: option.OptionText!, style: .default, handler: { (action) in
                    cell.optionLabel.text = option.OptionText!
                    category.0.SelectedOption = option
                    self.nextButton.isEnabled = true
                })
                
                optionSheet.addAction(action)
            }
            
            if optionSheet.actions.count > 0 {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    optionSheet.popoverPresentationController?.sourceView = self.tableView as UIView
                }
                
                self.present(optionSheet, animated: true, completion: nil)
            }
        }
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
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answers.removeAll()
        
        let date = Date()
        
        for category in self.categories {
            if category.0.SelectedOption != nil {
                let answer = SurveyAnswer()
                answer.CategoryId = category.0.CategoryId
                answer.OptionId = category.0.SelectedOption!.OptionId
                answer.AnswerDateUTC = date
                answer.AnswerDateDTO = date
                self.answers.append(answer)
            }
        }
        
        if self.answers.isEmpty {
            self.answers.append(SurveyAnswer())
        }
        
        super.getNextQuestion(sender)
    }
}
