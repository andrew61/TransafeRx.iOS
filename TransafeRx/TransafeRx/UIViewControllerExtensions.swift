//
//  UIViewControllerExtensions.swift
//  VoiceCrisisAlert
//
//  Created by Tachl on 6/30/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import KVNProgress
import UIColor_Hex_Swift
import ABPadLockScreen
import LocalAuthentication

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addDoneButtonOnKeyboard(textField: UITextField){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneKeyboardAction))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        textField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneKeyboardAction(){
        view.endEditing(true)
    }
    
    func kvnConfig() -> KVNProgressConfiguration{
        let config = KVNProgressConfiguration.default()
        config?.minimumSuccessDisplayTime = 0.5
        config?.circleStrokeForegroundColor = UIColor("#2e5673")
        config?.isFullScreen = true
        
        return config!
    }
    
    func showProgress(){
        KVNProgress.setConfiguration(kvnConfig())
        KVNProgress.show()
    }
    
    func dismissProgress(){
        KVNProgress.dismiss()
    }
    
    func dismissProgressError(){
        KVNProgress.showError(withStatus: "Error")
    }
    
    func dismissProgressSuccess(){
        KVNProgress.showSuccess(withStatus: "Success", completion: nil)
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
//
//    func showMessageDialog(animated: Bool = true, title: String = "", message: String = "") {
//        
//        // Create the dialog
//        let popup = PopupDialog(title: title, message: message, image: nil, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true, completion: nil)
//        // Create first button
//        let buttonOne = CancelButton(title: "DISMISS") {
//        }
//        
//        // Add buttons to dialog
//        popup.addButtons([buttonOne])
//        
//        // Present dialog
//        self.present(popup, animated: animated, completion: nil)
//    }
//    
//    func addDropDown(dropDown: DropDown, anchor: UIBarButtonItem){
//        dropDown.anchorView = anchor
//        
//        dropDown.dataSource = ["Personalize", "Account Settings", "Help"]
//        
//        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
//            switch(index){
//            case 0:
//                break
//            case 1:
//                break
//            case 2:
//                break
//            default: break
//            }
//        }
//    }
}
