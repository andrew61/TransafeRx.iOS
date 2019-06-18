//
//  FreeTextViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import UIKit
import KVNProgress

class SurveyTextViewController: SurveyViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 44.0
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        self.tableView.addGestureRecognizer(tapGesture)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "freeTextCell", for: indexPath) as! FreeTextCell
        
        if self.survey.ListColor != nil {
            cell.textView.textColor = UIColor(self.survey.ListColor!)
        }
        
        if self.survey.ListBackgroundColor != nil {
            cell.textView.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
            cell.contentView.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
            cell.backgroundColor = UIColor(self.survey.ListBackgroundColor!)
        }
        
        cell.textView.font = UIFont.applicationFontFor(id: self.survey.ListFontId, size: self.survey.ListFontSize)
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard(_:)))
        toolbar.items = [doneButton]
        
        cell.textView.inputAccessoryView = toolbar
        
        if self.question.Answer != nil {
            cell.textView.text = self.question.Answer!.AnswerText
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
    
    func dismissKeyboard(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? FreeTextCell {
            self.answer.AnswerText = cell.textView.text
            self.answers.append(self.answer)
            super.getNextQuestion(sender)
        }
    }
}
