//
//  SurveyRestartViewController.swift
//  MobileCMS
//
//  Created by Jonathan Tindall on 5/3/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class SurveyRestartViewController: ItemViewController {
    
    var survey: Survey!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.instructionsLabel.textColor = UIColor(self.survey.BodyColor ?? "")
        self.instructionsLabel.font = UIFont.applicationFontFor(id: self.survey.BodyFontId, size: self.survey.BodyFontSize)
        
        self.continueButton.tintColor = UIColor(self.survey.ButtonColor ?? "")
        self.continueButton.backgroundColor = UIColor(self.survey.ButtonBackgroundColor ?? "")
        self.continueButton.backgroundColor = self.continueButton.backgroundColor?.withAlphaComponent(CGFloat(self.survey.ButtonBackgroundAlpha ?? 1.0))
        self.continueButton.titleLabel?.font = UIFont.applicationFontFor(id: self.survey.ButtonFontId, size: self.survey.ButtonFontSize)
        self.continueButton.layer.cornerRadius = 5
        self.continueButton.layer.borderWidth = 0
        
        self.restartButton.tintColor = UIColor(self.survey.ButtonColor ?? "")
        self.restartButton.backgroundColor = UIColor(self.survey.ButtonBackgroundColor ?? "")
        self.restartButton.backgroundColor = self.restartButton.backgroundColor?.withAlphaComponent(CGFloat(self.survey.ButtonBackgroundAlpha ?? 1.0))
        self.restartButton.titleLabel?.font = UIFont.applicationFontFor(id: self.survey.ButtonFontId, size: self.survey.ButtonFontSize)
        self.restartButton.layer.cornerRadius = 5
        self.restartButton.layer.borderWidth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTheme(item: self.survey)
        self.setupToolbar(item: self.survey)
    }
    
    @IBAction func continueSurvey(_ sender: Any) {
        let vc = SurveyViewController()
        vc.survey = self.survey
        showProgress()
        vc.getNextQuestion { (vc) in
           self.dismissProgress()
                if vc != nil {
                    var viewControllers = [UIViewController]()
                    
                    if self.navigationController != nil {
                        viewControllers = self.navigationController!.viewControllers
                    }
                    
                    let index = viewControllers.index(of: self)
                    
                    if index != nil {
                        viewControllers.remove(at: index!)
                    }
                    
                    viewControllers.append(vc!)
                    
                    self.navigationController?.setViewControllers(viewControllers, animated: true)
                }
            
        }
    }
    
    @IBAction func restartSurvey(_ sender: Any) {
        showProgress()
        ApiManager.sharedManager.restartSurvey(self.survey.SurveyId) { (success) in
            self.dismissProgress()
                if success {
                    self.continueSurvey(sender)
                }
        }
    }
}
