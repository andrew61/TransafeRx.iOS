//
//  SurveyContentViewController.swift
//  MobileCMS
//
//  Created by Jonathan on 3/8/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import WebKit

class SurveyContentViewController: SurveyViewController {
    
    var webView: WKWebView!
    
    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.requiresUserActionForMediaPlayback = true
        
        self.webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView.allowsLinkPreview = true
        self.webView.isOpaque = false
        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
        
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.webView)
        
        let views = ["webView": self.webView]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[webView]|",
            options: [],
            metrics: nil,
            views: views as Any as! [String : Any]
        ))
        
        self.view.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[webView]|",
            options: [],
            metrics: nil,
            views: views as Any as! [String : Any]
        ))
        
        if self.question.Body != nil {
            self.webView.loadHTMLString(html: self.question.Body!, fontId: self.survey.BodyFontId, fontSize: self.survey.BodyFontSize, fontColor: self.survey.BodyColor)
        }
    }
    
    override func getNextQuestion(_ sender: AnyObject) {
        self.answers.removeAll()
        self.answers.append(SurveyAnswer())
        super.getNextQuestion(sender)
    }
}
