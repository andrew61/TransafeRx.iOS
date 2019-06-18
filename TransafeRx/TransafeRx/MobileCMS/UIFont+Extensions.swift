//
//  UIFont+Extensions.swift
//  MobileCMS
//
//  Created by Jonathan on 2/9/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

extension UIFont {
    class func applicationFontFor(id: Int, size: Int) -> UIFont {
        let font = UIFont()
        let fontName = font.fontNameFor(id: id)
        let fontSize = size == 0 ? UIFont.systemFontSize : CGFloat(size)
        
        return UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    func fontNameFor(id: Int) -> String {
        switch id {
        case 1:
            return "AmericanTypewriter-CondensedBold"
        case 2:
            return "AmericanTypewriter-Medium"
        case 3:
            return "AmericanTypewriter-CondensedBold"
        case 4:
            return "ArialMT"
        case 5:
            return "CourierNewPSMT"
        case 6:
            return "CourierNewPS-BoldMT"
        case 7:
            return "AmericanTypewriter-CondensedBold"
        case 8:
            return "AmericanTypewriter-CondensedBold"
        case 9:
            return "Futura-Medium"
        case 10:
            return "Georgia"
        case 11:
            return "GillSans"
        case 12:
            return "GillSans-Bold"
        case 13:
            return "Helvetica"
        case 14:
            return "HelveticaNeue"
        case 15:
            return "HelveticaNeue-CondensedBold"
        case 16:
            return "HelveticaNeue-Light"
        case 17:
            return "HelveticaNeue-UltraLight"
        case 18:
            return "HelveticaNeue-Medium"
        case 19:
            return "AmericanTypewriter-CondensedBold"
        case 20:
            return "HoeflerText-Regular"
        case 21:
            return "HoeflerText-BlackItalic"
        case 22:
            return "AmericanTypewriter-CondensedBold"
        case 23:
            return "AmericanTypewriter-CondensedBold"
        case 24:
            return "AmericanTypewriter-CondensedBold"
        case 25:
            return "AmericanTypewriter-CondensedBold"
        case 26:
            return "TimesNewRomanPSMT"
        case 27:
            return "TrebuchetMS"
        case 28:
            return "Verdana"
        case 29:
            return "SalvoSerifCond-Regular"
        case 30:
            return "BentonSans-Regular"
        case 31:
            return "BentonSans-RegularItalic"
        case 32:
            return "BentonSans-Bold"
        case 33:
            return "BentonSans-BoldItalic"
        case 34:
            return "BentonSans-Medium"
        case 35:
            return "BentonSans-MediumItalic"
        case 36:
            return "BentonSans-Light"
        case 37:
            return "BentonSans-LightItalic"
        default:
            return ""
        }
    }
}
