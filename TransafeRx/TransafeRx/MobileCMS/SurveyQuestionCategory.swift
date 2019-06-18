//
//  Category.swift
//  eHEARTT
//
//  Created by Tachl on 11/10/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation

class SurveyQuestionCategory: NSObject {
    var CategoryId: Int = 0
    var Name: String?
    
    var SelectedOption: SurveyQuestionOption?
    
    class func groupsWith(options: [SurveyQuestionOption]) -> [(SurveyQuestionCategory, Array<SurveyQuestionOption>)] {
        var groups = [(SurveyQuestionCategory, Array<SurveyQuestionOption>)]()
        var categoryIds = [Int]()
        
        for option in options {
            categoryIds.append(option.CategoryId)
        }
        
        let uniqueCategoryIds = Array(Set(categoryIds))
        
        for categoryId in uniqueCategoryIds {
            let category = SurveyQuestionCategory()
            category.CategoryId = categoryId
            
            var group = [SurveyQuestionOption]()
            
            for option in options {
                if option.CategoryId == categoryId {
                    category.Name = option.CategoryName
                    group.append(option)
                }
            }
            
            groups.append((category, group))
        }
        
        return groups
    }
}
