//
//  Enums.swift
//  MobileCMS
//
//  Created by Jonathan on 2/7/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

enum MenuTemplate: Int {
    case List = 6
    case ImageMap = 7
    case TabBar = 8
    case SideDrawer = 9
    case TopBar = 10
}

enum SurveyQuestionType: Int {
    case YesNo = 1
    case TrueFalse = 2
    case Scale = 3
    case Text = 4
    case Number = 5
    case DropDownList = 6
    case MCSingle = 7
    case MCMulti = 8
    case DateTime = 9
    case Date = 10
    case CategoryList = 11
    case ImageMap = 12
    case ImageUpload = 13
    case Content = 14
    case Ranking = 15
}

enum QuizQuestionType: Int {
    case TrueFalse = 1
    case MultipleChoice = 2
    case ShortAnswer = 3
    case MythFact = 4
    case CardDeck = 5
    case Content = 6
}

enum FormFieldType: Int {
    case Text = 1
    case Number = 2
    case Paragraph = 3
    case MultipleChoice = 4
    case DropDownList = 5
    case Address = 6
    case Date = 7
    case DateTime = 8
    case Time = 9
    case Email = 10
    case Phone = 11
    case Website = 12
    case Currency = 13
    case File = 14
    case Section = 15
    case ProfileFirstName = 16
    case ProfileLastName = 17
    case ProfilePhoneNumber = 18
    case ProfileNotificationType = 19
    case ProfileAddress1 = 20
    case ProfileAddress2 = 21
    case ProfileCity = 22
    case ProfileState = 23
    case ProfileZip = 24
    case ProfileCountry = 25
    case ProfileEmail = 26
    case ProfilePassword = 27
}

enum ShapeType: Int {
    case Circle = 0
    case Rectangle = 1
    case Polygon = 2
}

enum ItemType: Int {
    case Quiz = 1
    case Video = 2
    case Survey = 3
    case Content = 5
    case Agreement = 6
    case Menu = 7
    case Accordion = 8
    case Resource = 9
    case CustomItem = 10
    case MemoryGame = 11
    case DialogCards = 12
    case Form = 13
    case Achievement = 14
    case Pager = 15
}

enum NavigationTemplate: Int {
    case Template1 = 1
    case Template2 = 2
    case Template3 = 3
}

enum NavigationType: Int {
    case Push = 1
    case PushNewContext = 2
    case PushClearContext = 3
    case PopupModal = 4
    case PopupFullScreen = 5
    case Back = 6
}

enum TransitionType: Int {
    case Slide = 1
}

enum ToolbarAction: Int {
    case GoToItem = 1
}

enum ItemActionType: Int {
    case ShowItemModal = 1
    case ShowItemFullScreen = 2
    case Email = 3
}
