//
//  Enums.swift
//  VoiceCrisisAlert
//
//  Created by Tachl on 6/6/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

enum HomeType: Int{
    case Pain = 0
    case Voice = 1
    case History = 2
    case Settings = 3
    case Crisis = 4
    case Disease = 5
}

enum DiseaseAgeType: Int{
    case Kids5 = 0
    case Kids9 = 1
    case Teens12 = 2
    case Teens15 = 3
    case Adults = 4
    case Parents = 5
}

enum AvatarPart: Int{
    case Skin = 0
    case Hair = 1
    case Shirt = 2
    case Pants = 3
    case Shoes = 4
    case Accessory = 5
}

enum MedicationType: Int{
    case Regular = 1
    case Home = 2
    case ED = 3
}

enum Colors: Int{
    case gray = 0, blue, orange, green, purple
}

enum FontColors: Int{
    case black = 0, white = 1
}
