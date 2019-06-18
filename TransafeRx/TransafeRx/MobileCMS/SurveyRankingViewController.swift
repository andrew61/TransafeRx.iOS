//
//  SurveyRankingViewController.swift
//  TransafeRx
//
//  Created by Tachl on 11/14/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import UIKit

class SurveyRankingViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableView.automaticDimension
        self.tableView.separatorColor = UIColor(self.question.SeparatorColor ?? "#aaaaaa")
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.isEditing = true
        self.nextButton.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let option = self.question.Options[sourceIndexPath.row]
        self.question.Options.remove(at: sourceIndexPath.row)
        self.question.Options.insert(option, at: destinationIndexPath.row)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.question.Options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankingCell", for: indexPath)
        let option = self.question.Options[indexPath.row]
        
        cell.textLabel?.text = option.OptionText
        cell.textLabel?.textColor = UIColor(self.question.ListColor ?? "")
        cell.textLabel?.font = UIFont.applicationFontFor(id: self.question.ListFontId, size: self.question.ListFontSize)
        cell.contentView.backgroundColor = UIColor(self.question.ListBackgroundColor ?? "")
        cell.contentView.backgroundColor = cell.contentView.backgroundColor?.withAlphaComponent(CGFloat(self.question.ListBackgroundAlpha ?? 1.0))
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
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answers.removeAll()
        
        let date = Date()
        
        for (index, option) in self.question.Options.enumerated() {
            let answer = SurveyAnswer()
            answer.OptionId = option.OptionId
            answer.Rank = index + 1
            answer.AnswerDateUTC = date
            answer.AnswerDateDTO = date
            self.answers.append(answer)
        }
        
        super.getNextQuestion(sender)
    }
}
