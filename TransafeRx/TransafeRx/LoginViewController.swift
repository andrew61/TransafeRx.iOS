//
//  LoginViewController.swift
//  WeightManagement
//
//  Created by Tachl on 11/30/16.
//  Copyright © 2016 Tachl. All rights reserved.
//

import Foundation
import KVNProgress
import UIColor_Hex_Swift
import ABPadLockScreen
import LocalAuthentication

class LoginViewController : UIViewController, ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate {
    
    @IBOutlet weak var tf_login: UITextField!
    @IBOutlet weak var tf_password: UITextField!
    @IBOutlet weak var btn_login: UIButton!
    @IBOutlet weak var btn_forgot: UIButton!
    @IBOutlet weak var btn_create: UIButton!
    @IBOutlet weak var lbl_invalid: UILabel!
    
    private(set) var thePin: String?
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Login"
        
        KeychainManager.sharedManager.setIsLoggedIn(loggedIn: false)
        
        addDoneButtonOnKeyboard(textField: tf_login)
        addDoneButtonOnKeyboard(textField: tf_password)
        
        if KeychainManager.sharedManager.keychain["username"] != nil{
            self.tf_login.text! = KeychainManager.sharedManager.keychain["username"]!
        }
        
        self.hideKeyboardWhenTappedAround()
        
        let backgroundView = UIView(frame: self.view.frame)
        backgroundView.backgroundColor = UIColor("#2e5673")
        
        ABPadLockScreenView.appearance().backgroundColor = UIColor.blue
        ABPadLockScreenView.appearance().insertSubview(backgroundView, at: 0)
        ABPadLockScreenView.appearance().labelColor = UIColor.white
        
        let buttonLineColor = UIColor(red: 229/255, green: 180/255, blue: 46/255, alpha: 1)
        ABPadButton.appearance().backgroundColor = UIColor.clear
        ABPadButton.appearance().borderColor = UIColor.clear
        ABPadButton.appearance().selectedColor = buttonLineColor
        ABPinSelectionView.appearance().selectedColor = buttonLineColor
        
        if KeychainManager.sharedManager.keychain["username"] != nil{
            if KeychainManager.sharedManager.keychain["pin"] != nil{
                if !(KeychainManager.sharedManager.keychain["pin"]?.contains("nil"))!{
                    self.automaticSignIn()
                }
            }else{
                if KeychainManager.sharedManager.keychain["touchid"] != nil{
                    self.automaticSignIn()
                }
            }
        }
        
//        UIApplication.shared.openURL(URL(string: "https://itunes.apple.com/us/app/apple-store/id1285348991?mt=8")!)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        return
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    func presentPadLockSetup(_ setup: Bool){
        if KeychainManager.sharedManager.keychain["touchid"] == nil{
            if setup{
                let lockScreenText = "Create a pin"
                let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: lockScreenText)
                lockSetupScreen?.tapSoundEnabled = true
                lockSetupScreen?.errorVibrateEnabled = true
                lockSetupScreen?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                lockSetupScreen?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                present(lockSetupScreen!, animated: true, completion: nil)
            }else{
                
                let lockScreen = ABPadLockScreenViewController(delegate: self, complexPin: false)
                lockScreen?.setAllowedAttempts(3)
                lockScreen?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                lockScreen?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                
                present(lockScreen!, animated: true, completion: nil)
            }
        }else{
            if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                prepareTouchId()
            }
        }
    }
    
    func prepareTouchId(){
        context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Logging in with Touch ID",
                               reply: { (success : Bool, error : Error? ) -> Void in
                                
                                DispatchQueue.main.async(execute: {
                                    if success {
                                        KeychainManager.sharedManager.keychain["touchid"] = "true"
                                        self.dismiss(animated: true, completion: nil)
                                        ApiManager.sharedManager.saveLoginInformation(LoginInformation())
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMenuViewController") as! HomeMenuViewController
                                        self.show(vc, sender: self)
                                    }
                                    
                                    if error != nil {
                                        
                                        KeychainManager.sharedManager.keychain["touchid"] = nil
                                        var message = ""
                                        var showAlert = false
                                        
                                        if let laError = error as? LAError{
                                            print("ERROR CODE: \(laError.code); DESCRIPTION \(laError.localizedDescription)")
                                            switch(laError.code){
                                            case .userCancel:
                                                showAlert = false
                                            default:
                                                message = laError.localizedDescription
                                                showAlert = true
                                            }
                                        }
                                        message = "There was a problem verifying your identity."
                                        
                                        let alertView = UIAlertController(title: "Error",
                                                                          message: message as String, preferredStyle:.alert)
                                        let okAction = UIAlertAction(title: "Darn!", style: .default, handler: nil)
                                        alertView.addAction(okAction)
                                        if showAlert {
                                            self.present(alertView, animated: true, completion: nil)
                                        }
                                    }
                                })
                                
        })
    }
    
    func automaticSignIn(){
        showProgress()
        
        ApiManager.sharedManager.loginUser(KeychainManager.sharedManager.keychain["username"]!, password: KeychainManager.sharedManager.keychain["password"]!){
            response in
            if (response.AccessToken.characters.count) < 1{//error
                KVNProgress.showError(withStatus: "Error")
                self.lbl_invalid.isHidden = false
            }else{
                KVNProgress.showSuccess(withStatus: "Success", completion: {
                    if KeychainManager.sharedManager.keychain["pin"] != nil{
                        self.thePin = KeychainManager.sharedManager.keychain["pin"]
                        self.presentPadLockSetup(false)
                    }else{
                        self.presentPadLockSetup(true)
                    }
                })
                
                self.lbl_invalid.isHidden = true
            }
        }
    }
    
    @IBAction func loginAction(_ sender: AnyObject) {
        view.endEditing(true)
        self.lbl_invalid.isHidden = true
        
        KVNProgress.show()
        ApiManager.sharedManager.loginUser(tf_login.text!, password: tf_password.text!){
            response in
            if (response.AccessToken.characters.count) < 1{//error
                KVNProgress.showError(withStatus: "Error")
                
                self.lbl_invalid.isHidden = false
            }else{
                KVNProgress.showSuccess(withStatus: "Success", completion: {
                    self.presentPadLockSetup(true)
                })
                
                self.lbl_invalid.isHidden = true
                KeychainManager.sharedManager.keychain["username"] = self.tf_login.text!
                KeychainManager.sharedManager.keychain["password"] = self.tf_password.text!
            }
        }
    }
    
    @IBAction func forgotAction(_ sender: UIButton) {
        var alertTf: UITextField?
        
        let alertController = UIAlertController(title: "Reset Password", message: "Provide Email", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (completed) in
            KVNProgress.show()
            ApiManager.sharedManager.resetPassword((alertTf?.text)!, completion: { (successful) in
                KVNProgress.dismiss(completion: {
                    if successful{
                        let alertController = UIAlertController(title: "Check Email", message: "Reset Password link sent to email: \((alertTf?.text)!)", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (completed) in
                        }
                        alertController.addAction(dismissAction)
                        self.present(alertController, animated: true, completion: nil)
                    }else{
                        let alertController = UIAlertController(title: "Incorrect Email Provided", message: "Not a valid email address", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (completed) in
                        }
                        alertController.addAction(dismissAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            })
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (completed) in
        }
        
        alertController.addTextField { (textField) in
            textField.keyboardType = .emailAddress
            textField.placeholder = "Email"
            if let username = KeychainManager.sharedManager.keychain["username"]{
                textField.text! = username
            }
            alertTf = textField
        }
        
        alertController.addAction(dismissAction)
        alertController.addAction(submitAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Lock Screen Setup Delegate
    func pinSet(_ pin: String!, padLockScreenSetupViewController padLockScreenViewController: ABPadLockScreenSetupViewController!) {
        thePin = pin
        print("Created Pin \(pin)")
        KeychainManager.sharedManager.keychain["pin"] = pin
        dismiss(animated: true, completion: nil)
        ApiManager.sharedManager.saveLoginInformation(LoginInformation())
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMenuViewController") as! HomeMenuViewController
        self.show(vc, sender: self)
    }
    
    func unlockWasCancelledForSetupViewController(padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Lock Screen Delegate
    func padLockScreenViewController(_ padLockScreenViewController: ABPadLockScreenViewController!, validatePin pin: String!) -> Bool {
        print("Validating Pin \(pin)")
        return thePin == pin
    }
    
    func unlockWasSuccessful(for padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Successful!")
        dismiss(animated: true, completion: nil)
        ApiManager.sharedManager.saveLoginInformation(LoginInformation())
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeMenuViewController") as! HomeMenuViewController
        self.show(vc, sender: self)
    }
    
    func unlockWasUnsuccessful(_ falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
    }
    
    func unlockWasCancelled(forSetupViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        print("Unlock Canceled")
        KeychainManager.sharedManager.keychain["pin"] = nil
        dismiss(animated: true, completion: nil)
    }
    
    func unlockWasCancelled(for padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Canceled")
        KeychainManager.sharedManager.keychain["pin"] = nil
        dismiss(animated: true, completion: nil)
    }

    func touchId(for padLockScreenViewController: ABPadLockScreenViewController!) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            prepareTouchId()
        }else{
            let alertView = UIAlertController(title: "Error",
                                              message: "TouchID Not Available", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "Darn!", style: .default, handler: nil)
            alertView.addAction(okAction)
            padLockScreenViewController.present(alertView, animated: true, completion: nil)
        }
    }
    
    func touchId(forSetupViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            prepareTouchId()
        }else{
            let alertView = UIAlertController(title: "Error",
                                              message: "TouchID Not Available", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "Darn!", style: .default, handler: nil)
            alertView.addAction(okAction)
            padLockScreenViewController.present(alertView, animated: true, completion: nil)
        }
    }
}
