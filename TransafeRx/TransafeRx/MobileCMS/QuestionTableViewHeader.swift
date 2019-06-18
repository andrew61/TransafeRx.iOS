//
//  CollapsibleTableViewHeader.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 5/30/16.
//  Copyright © 2016 Yong Su. All rights reserved.
//

import UIKit

class QuestionTableViewHeader: UITableViewHeaderFooterView {
    
    var questionView = UIView()
    var questionLabel = UILabel()
    var questionImageView = UIImageView()
    var questionImageViewVerticalConstraints = [NSLayoutConstraint()]
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        questionView.translatesAutoresizingMaskIntoConstraints = false
        
        questionLabel.numberOfLines = 0
        questionLabel.lineBreakMode = .byWordWrapping
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        questionImageView.contentMode = .scaleAspectFit
        questionImageView.translatesAutoresizingMaskIntoConstraints = false
        
        questionView.addSubview(questionLabel)
        contentView.addSubview(questionView)
        contentView.addSubview(questionImageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.questionView.superview != nil {
            let views = [
                "questionView" : self.questionView,
                "questionLabel" : self.questionLabel,
                "questionImageView" : self.questionImageView
            ] as [String : Any]
            
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|[questionView]|",
                options: [],
                metrics: nil,
                views: views
            ))
            
            contentView.addConstraint(NSLayoutConstraint(
                item: self.questionView,
                attribute: .top,
                relatedBy: .greaterThanOrEqual,
                toItem: self.contentView,
                attribute: .topMargin,
                multiplier: 1.0,
                constant: 0.0
            ))
            
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-20-[questionLabel]-20-|",
                options: [],
                metrics: nil,
                views: views
            ))
            
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-20-[questionLabel]-20-|",
                options: [],
                metrics: nil,
                views: views
            ))
            
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "H:|-20-[questionImageView]-20-|",
                options: [],
                metrics: nil,
                views: views
            ))
            
            contentView.addConstraints(NSLayoutConstraint.constraints(
                withVisualFormat: "V:[questionImageView]-20-[questionView]-20-|",
                options: [],
                metrics: nil,
                views: views
            ))
            
            contentView.addConstraint(NSLayoutConstraint(
                item: self.questionImageView,
                attribute: .height,
                relatedBy: .lessThanOrEqual,
                toItem: nil,
                attribute: .notAnAttribute,
                multiplier: 1.0,
                constant: 100.0
            ))
            
            self.questionImageViewVerticalConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "V:|-20-[questionImageView]",
                options: [],
                metrics: nil,
                views: views
            )
        }
    }
}
