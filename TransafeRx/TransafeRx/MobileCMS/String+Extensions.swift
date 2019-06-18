//
//  String+Extensions.swift
//  MobileCMS
//
//  Created by Jonathan on 3/1/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import Alamofire

extension String {
    
    public func trim() -> String {
        return self.replace(" ", replacement: "")
    }
    
    public var htmlAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8, allowLossyConversion: true) else { return nil }
        do {
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    public func htmlAttributedString(fontId: Int, fontSize: Int, fontColor: String?) -> NSAttributedString? {
        let font = UIFont.applicationFontFor(id: fontId, size: fontSize)
        let html = String(format: "<html><head><style>@font-face { font-family: '%@'; }</style></head><body style='color: %@; font-size: %f; font-family: \"%@\"; margin: 0; padding: 0;'>%@</body></html>",
                          font.fontName,
                          fontColor ?? "#000000",
                          font.pointSize,
                          font.fontName,
                          self)
        return html.htmlAttributedString
    }
    
    public func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    public func width(withConstraintedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
}

