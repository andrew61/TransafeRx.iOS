//
//  SurveyViewController.swift
//  eHEARTT
//
//  Created by Tachl on 11/7/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import KeychainAccess
import KVNProgress
import WebKit

class SurveyViewController: ItemViewController, AchievementAlertDelegate {
    
    var survey: Survey!
    var question: SurveyQuestion!
    var selectedOption: SurveyQuestionOption?
    var selectedOptions = Set<SurveyQuestionOption>()
    var answers = [SurveyAnswer]()
    var questionImage: UIImage?
    var feedbackView: WKWebView?
    var chromeView: UIView?
    var didGoBack: Bool = false
    var isBeingSubmitted: Bool = false
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextButton.tintColor = UIColor(self.question.ButtonColor ?? "")
        self.nextButton.backgroundColor = UIColor(self.question.ButtonBackgroundColor ?? "")
        self.nextButton.backgroundColor = self.nextButton.backgroundColor?.withAlphaComponent(CGFloat(self.question.ButtonBackgroundAlpha ?? 1.0))
        self.nextButton.titleLabel?.font = UIFont.applicationFontFor(id: self.question.ButtonFontId, size: self.question.ButtonFontSize)
        self.nextButton.layer.cornerRadius = 5
        self.nextButton.layer.borderWidth = 0
        
        self.backButton.tintColor = UIColor(self.question.ButtonColor ?? "")
        self.backButton.backgroundColor = UIColor(self.question.ButtonBackgroundColor ?? "")
        self.backButton.backgroundColor = self.backButton.backgroundColor?.withAlphaComponent(CGFloat(self.question.ButtonBackgroundAlpha ?? 1.0))
        self.backButton.titleLabel?.font = UIFont.applicationFontFor(id: self.question.ButtonFontId, size: self.question.ButtonFontSize)
        self.backButton.layer.cornerRadius = 5
        self.backButton.layer.borderWidth = 0
        
        if self.question.IsFirstQuestion {
            self.backButton.isEnabled = false
        }
        
        self.progressView.progressTintColor = UIColor(self.question.ProgressBarColor ?? "")
        self.progressView.trackTintColor = UIColor(self.question.ProgressBarBackgroundColor ?? "")
        self.progressView.trackTintColor = self.progressView.trackTintColor?.withAlphaComponent(CGFloat(self.question.ProgressBarBackgroundAlpha ?? 1.0))
        self.progressView.progressViewStyle = .bar
        self.progressView.setProgress(self.getProgress(), animated: true)
        
        if self.previousItemVC != nil && (self.navigationController?.viewControllers.contains(self.previousItemVC!) ?? false) {
            let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            backButton.setImage(UIImage(named: "ic_chevron_left", in: Bundle(identifier: "com.pghs.MobileCMS"), compatibleWith: nil), for: .normal)
            backButton.addTarget(self, action: #selector(self.goToPreviousItem), for: .touchUpInside)
            backButton.imageEdgeInsets = UIEdgeInsets.zero
            
            let negativeSpacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            negativeSpacer.width = -15
            
            self.navigationItem.leftBarButtonItems = [negativeSpacer, UIBarButtonItem(customView: backButton)]
        }
        else {
            var barButtonItems = [UIBarButtonItem]()
            
            if self.navigationItem.leftBarButtonItems != nil {
                for barButtonItem in self.navigationItem.leftBarButtonItems! {
                    if barButtonItem.tag != -1 && barButtonItem.tag != 1 {
                        barButtonItems.append(barButtonItem)
                    }
                }
            }
            
            self.navigationItem.leftBarButtonItems = barButtonItems
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTheme(item: self.survey)
        self.setupToolbar(item: self.survey)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        KVNProgress.dismiss()
    }
    
    @IBAction func getNextQuestion(_ sender: AnyObject) {
        if !self.isBeingSubmitted {
            self.isBeingSubmitted = true
            KVNProgress.show()
            if self.feedbackView != nil {
                self.getNextQuestion(completion: { (vc) in
                    if vc != nil {
                        KVNProgress.dismiss(completion: {
                            vc?.previousItemVC = self.previousItemVC
                            self.setTransitionForNextQuestion()
                            self.show(vc!, sender: nil)
                            self.isBeingSubmitted = false
                        })
                    }
                    else {
                        self.getNextItem(item: self.survey, completion: { (vc, item) in
                            KVNProgress.dismiss(completion: {
                                if vc != nil {
                                    self.navigate(to: vc!, navigationTypeId: item?.Navigation?.NavigationTypeId, transitionTypeId: item?.Navigation?.TransitionTypeId)
                                }
                                else {
                                    if ItemNavigationController.previousItemVC != nil
                                        && (self.navigationController?.viewControllers.contains(ItemNavigationController.previousItemVC!))! {
                                        self.navigationController?.popToViewController(ItemNavigationController.previousItemVC!, animated: true)
                                    }
                                }
                                
                                self.isBeingSubmitted = false
                            })
                        })
                    }
                })
            }
            else {
                ApiManager.sharedManager.postSurveyAnswers(self.survey.SurveyId, questionId: self.question.QuestionId, answers: self.answers) { (success) in
                    if success {
                        if self.selectedOption?.Feedback != nil {
                            KVNProgress.dismiss(completion: {
                                self.chromeView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                self.chromeView?.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
                                
                                self.view.addSubview(self.chromeView!)
                                
                                let configuration = WKWebViewConfiguration()
                                configuration.allowsInlineMediaPlayback = true
                                configuration.allowsPictureInPictureMediaPlayback = true
                                configuration.requiresUserActionForMediaPlayback = true
                                
                                self.feedbackView = WKWebView(frame: CGRect.zero, configuration: configuration)
                                self.feedbackView?.translatesAutoresizingMaskIntoConstraints = false
                                self.feedbackView?.allowsLinkPreview = true
                                self.feedbackView?.isOpaque = false
                                self.feedbackView?.layer.cornerRadius = 5
                                self.feedbackView?.scrollView.layer.cornerRadius = 5
                                self.feedbackView?.backgroundColor = UIColor(self.selectedOption?.FeedbackBackgroundColor ?? "")
                                self.feedbackView?.backgroundColor = self.feedbackView?.backgroundColor?.withAlphaComponent(CGFloat(self.selectedOption?.FeedbackBackgroundAlpha ?? 1.0))
                                self.view.addSubview(self.feedbackView!)
                                
                                let views = [
                                    "topLayoutGuide" : self.topLayoutGuide,
                                    "feedbackView" : self.feedbackView!,
                                    "nextButton" : self.nextButton,
                                    "backButton" : self.backButton
                                    ] as [String : Any]
                                
                                self.view.addConstraints(NSLayoutConstraint.constraints(
                                    withVisualFormat: "V:[topLayoutGuide]-8-[feedbackView]",
                                    options: [],
                                    metrics: nil,
                                    views: views
                                ))
                                
                                self.view.addConstraints(NSLayoutConstraint.constraints(
                                    withVisualFormat: "V:[feedbackView]-8-[nextButton]",
                                    options: [],
                                    metrics: nil,
                                    views: views
                                ))
                                
                                self.view.addConstraints(NSLayoutConstraint.constraints(
                                    withVisualFormat: "V:[feedbackView]-8-[backButton]",
                                    options: [],
                                    metrics: nil,
                                    views: views
                                ))
                                
                                self.view.addConstraints(NSLayoutConstraint.constraints(
                                    withVisualFormat: "H:|-8-[feedbackView]-8-|",
                                    options: [],
                                    metrics: nil,
                                    views: views
                                ))
                                
                                self.feedbackView!.loadHTMLString(html: self.selectedOption!.Feedback!, fontId: self.selectedOption!.FeedbackFontId, fontSize: self.selectedOption!.FeedbackFontSize, fontColor: self.selectedOption!.FeedbackColor)
                                
                                self.view.bringSubviewToFront(self.feedbackView!)
                                self.view.bringSubviewToFront(self.backButton)
                                self.view.bringSubviewToFront(self.nextButton)
                                self.view.bringSubviewToFront(self.progressView)
                                self.isBeingSubmitted = false
                            })
                        }
                        else {
                            self.getNextQuestion(completion: { (vc) in
                                if vc != nil {
                                    KVNProgress.dismiss(completion: {
                                        vc?.previousItemVC = self.previousItemVC
                                        self.setTransitionForNextQuestion()
                                        self.show(vc!, sender: nil)
                                        self.isBeingSubmitted = false
                                    })
                                }
                                else {
                                    self.getNextItem(item: self.survey, completion: { (vc, item) in
                                        KVNProgress.dismiss(completion: {
                                            if vc != nil {
                                                self.navigate(to: vc!, navigationTypeId: item?.Navigation?.NavigationTypeId, transitionTypeId: item?.Navigation?.TransitionTypeId)
                                            }
                                            else {
                                                //                                                        if ItemNavigationController.previousItemVC != nil
                                                //                                                            && (self.navigationController?.viewControllers.contains(ItemNavigationController.previousItemVC!))! {
                                                //                                                            self.navigationController?.popToViewController(ItemNavigationController.previousItemVC!, animated: true)
                                                //                                                        }
                                                self.navigationController?.popToViewController(Globals.baseVC!, animated: true)
                                            }
                                            
                                            self.isBeingSubmitted = false
                                        })
                                    })
                                }
                            })
                        }
                    }
                    else {
                        KVNProgress.dismiss(completion: {
                            self.isBeingSubmitted = false
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func getPreviousQuestion(_ sender: AnyObject) {
        KVNProgress.show()
        self.getPreviousQuestion { (vc) in
            KVNProgress.dismiss(completion: {
                if vc != nil {
                    vc!.didGoBack = true
                    self.setTransitionForPreviousQuestion()
                    self.show(vc!, sender: nil)
                }
            })
        }
    }
}

extension SurveyViewController {
    func getNextQuestion(completion: @escaping (SurveyViewController?) -> ()) {
        ApiManager.sharedManager.getNextSurveyQuestion(self.survey.SurveyId) { (question) in
            if question != nil {
                self.getQuestion(question: question!, completion: { (vc) in
                    completion(vc)
                })
            }
            else {
                completion(nil)
            }
        }
    }
    
    func getPreviousQuestion(completion: @escaping (SurveyViewController?) -> ()) {
        ApiManager.sharedManager.getPreviousSurveyQuestion(self.survey.SurveyId, self.question.QuestionId) { (question) in
            if question != nil {
                self.getQuestion(question: question!, completion: { (vc) in
                    completion(vc)
                })
            }
            else {
                completion(nil)
            }
        }
    }
    
    func getQuestion(question: SurveyQuestion, completion: @escaping (SurveyViewController?) -> ()) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        
        if let questionType = SurveyQuestionType(rawValue: question.QuestionTypeId) {
            switch questionType {
            case .YesNo:
                    let vc = storyboard.instantiateViewController(withIdentifier: "surveyMultipleChoiceVC") as! SurveyMultipleChoiceViewController
                    vc.item = self.survey
                    vc.survey = self.survey
                    vc.question = question
                    completion(vc)
            case .TrueFalse:
                    let vc = storyboard.instantiateViewController(withIdentifier: "surveyMultipleChoiceVC") as! SurveyMultipleChoiceViewController
                    vc.item = self.survey
                    vc.survey = self.survey
                    vc.question = question
                    completion(vc)
            case .MCSingle:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyMultipleChoiceVC") as! SurveyMultipleChoiceViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                completion(vc)
            case .MCMulti:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyMultipleChoiceVC") as! SurveyMultipleChoiceViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                vc.allowMultipleSelections = true
                completion(vc)
            case .DropDownList:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyDropDownListVC") as! SurveyDropDownListViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                completion(vc)
            case .CategoryList:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyCategoryListVC") as! SurveyCategoryListViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                completion(vc)
            case .Content:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyContentVC") as! SurveyContentViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                completion(vc)
            case .Ranking:
                let vc = storyboard.instantiateViewController(withIdentifier: "surveyRankingVC") as! SurveyRankingViewController
                vc.item = self.survey
                vc.survey = self.survey
                vc.question = question
                completion(vc)
            default: break
            }
        }
        else {
            completion(nil)
        }
    }
    
    func getProgress() -> Float {
        if self.question.QuestionOrder == 1 {
            return 0.0
        }
        
        let progress = (Float(self.survey.TotalQuestions) * Float(self.question.QuestionOrder)) / (Float(self.survey.TotalQuestions) * Float(self.survey.TotalQuestions))
        
        return progress
    }
    
    func setTransitionForNextQuestion() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        //self.navigationController?.view.layer.add(transition, forKey: kCATransition)
    }
    
    func setTransitionForPreviousQuestion() {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
    }
    
    func achievementAlertDidDismiss() {
        KVNProgress.show()
        self.getNextItem(item: self.survey, completion: { (vc, item) in
            KVNProgress.dismiss(completion: {
                if vc != nil {
                    self.navigate(to: vc!, navigationTypeId: item?.Navigation?.NavigationTypeId, transitionTypeId: item?.Navigation?.TransitionTypeId)
                }
                else {
                    if ItemNavigationController.previousItemVC != nil
                        && (self.navigationController?.viewControllers.contains(ItemNavigationController.previousItemVC!))! {
                        self.navigationController?.popToViewController(ItemNavigationController.previousItemVC!, animated: true)
                    }
                }
            })
        })
    }
}
