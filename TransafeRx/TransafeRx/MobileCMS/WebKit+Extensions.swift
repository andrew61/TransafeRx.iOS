//
//  WebKit+Extensions.swift
//  SMASH
//
//  Created by Tachl on 11/9/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

import Foundation
import WebKit

extension WKWebView {
    
    func loadHTMLString(html: String, fontId: Int, fontSize: Int, fontColor: String?) -> Void {
        let font = UIFont.applicationFontFor(id: fontId, size: fontSize)
        let html = String(format: "<html><head>%@<style>@font-face { font-family: '%@'; src: url('%@.otf'); }</style></head><body style='color: %@; font-size: %f; font-family: \"%@\"; margin: 0; padding: 0;'>%@</body></html>",
                          "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'>",
                          font.fontName,
                          font.fontName,
                          fontColor ?? "#000000",
                          font.pointSize,
                          font.fontName,
                          html)
        
        self.loadHTMLString(html, baseURL: Bundle(identifier: "com.pghs.MobileCMS")?.bundleURL)
    }
}
