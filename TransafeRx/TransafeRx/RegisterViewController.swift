//
//  RegisterViewController.swift
//  WeightManagement
//
//  Created by Tachl on 4/17/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import KeychainAccess
import KVNProgress
import UIColor_Hex_Swift
import ABPadLockScreen
import LocalAuthentication

class RegisterViewController: UIViewController, ABPadLockScreenSetupViewControllerDelegate, ABPadLockScreenViewControllerDelegate {
    
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var confirmTf: UITextField!
    
    let keychain = Keychain()
    
    private(set) var thePin: String?
    var context = LAContext()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.hideKeyboardWhenTappedAround()

        addDoneButtonOnKeyboard(textField: emailTf)
        addDoneButtonOnKeyboard(textField: passwordTf)
        addDoneButtonOnKeyboard(textField: confirmTf)

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
    
    func presentPadLockSetup(){
        let lockSetupScreen = ABPadLockScreenSetupViewController(delegate: self, complexPin: false, subtitleLabelText: "Create a pin")
        lockSetupScreen?.tapSoundEnabled = true
        lockSetupScreen?.errorVibrateEnabled = true
        lockSetupScreen?.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        lockSetupScreen?.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        present(lockSetupScreen!, animated: true, completion: nil)
    }
    
    func prepareTouchId(){
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Logging in with Touch ID",
                                   reply: { (success : Bool, error : Error? ) -> Void in
                                    
                                    DispatchQueue.main.async(execute: {
                                        if success {
                                            KeychainManager.sharedManager.keychain["touchid"] = "true"
                                            self.dismiss(animated: true, completion: nil)
                                            ApiManager.sharedManager.saveLoginInformation(LoginInformation())
                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as! HomeTabBarViewController
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
                                            showAlert = true
                                            
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
        }else{
            let alertView = UIAlertController(title: "Error",
                                              message: "TouchID Not Available", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "Darn!", style: .default, handler: nil)
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
    }

    @IBAction func registerAction(_ sender: UIButton) {
        view.endEditing(true)
        showProgress()
        
        ApiManager.sharedManager.registerUser(emailTf.text!, password: passwordTf.text!, confirmPassword: confirmTf.text!) { (successful) in
            if successful{
                ApiManager.sharedManager.loginUser(self.emailTf.text!, password: self.passwordTf.text!){
                    response in
                    if (response.AccessToken.characters.count) < 1{//error
                        KVNProgress.showError(withStatus: "Error")
                    }else{
                        KVNProgress.showSuccess(withStatus: "Success", completion: {
                            self.presentPadLockSetup()
                        })
                        KeychainManager.sharedManager.keychain["username"] = self.emailTf.text!
                        KeychainManager.sharedManager.keychain["password"] = self.passwordTf.text!
                    }
                }
            }else{
                KVNProgress.showError(withStatus: "Error")
            }
        }
    }
    
    @IBAction func forgotAction(_ sender: UIButton) {
        var alertTf: UITextField?
        
        let alertController = UIAlertController(title: "Reset Password", message: "Provide Email", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (completed) in
            self.showProgress()
            ApiManager.sharedManager.resetPassword((alertTf?.text)!, completion: { (successful) in
                self.dismissProgress()
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
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel) { (completed) in
        }
        
        alertController.addTextField { (textField) in
            textField.keyboardType = .emailAddress
            textField.placeholder = "Email"
            if KeychainManager.sharedManager.keychain["username"] != nil{
                textField.text! = KeychainManager.sharedManager.keychain["username"]!
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as! HomeTabBarViewController
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as! HomeTabBarViewController
        self.show(vc, sender: self)
    }
    
    func unlockWasUnsuccessful(_ falsePin: String!, afterAttemptNumber attemptNumber: Int, padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Failed Attempt \(attemptNumber) with incorrect pin \(falsePin)")
    }
    
    func unlockWasCancelled(forSetupViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        print("Unlock Canceled")
        dismiss(animated: true, completion: nil)
    }
    
    func unlockWasCancelled(for padLockScreenViewController: ABPadLockScreenViewController!) {
        print("Unlock Canceled")
        dismiss(animated: true, completion: nil)
    }
    
    func touchId(for padLockScreenViewController: ABPadLockScreenViewController!) {
        prepareTouchId()
    }
    
    func touchId(forSetupViewController padLockScreenViewController: ABPadLockScreenAbstractViewController!) {
        prepareTouchId()
    }
}
