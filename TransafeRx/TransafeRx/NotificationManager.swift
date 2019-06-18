//
//  NotificationManager.swift
//  TransafeRx
//
//  Created by Tachl on 9/14/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

open class NotificationManager{
    
    static let sharedManager = NotificationManager()
    
    let remoteNotifications = NSMutableArray()
    
    var currentController: UIViewController?
    
    // MARK: - Initialization
    public init(){
        
    }
    
    func processRemoteNotificationSound(userInfo: [AnyHashable : Any]){
        if let _ = userInfo["UserMedicationId"] as? String{
            //AudioPlayer.sharedManager.playAudioFile(withName: AudioPlayer.sharedManager.aniticipateFile)
            AudioPlayer.sharedManager.playSystemSound(withId: 1020)
        }
    }
    
//    func processRemoteNotification(userInfo: [AnyHashable : Any]){
//        let activity = MedicationActivity()
//        activity.ActivityTypeId = 1
//        
//        if let userMedicationId = userInfo["UserMedicationId"] as? String{
//            activity.UserMedicationId = Int(userMedicationId)
//        }
//        
//        if let scheduleId = userInfo["ScheduleId"] as? String{
//            activity.ScheduleId = Int(scheduleId)
//        }
//        
//        if let scheduleTime = userInfo["ScheduleTime"] as? String{
//            let calendar = Calendar(identifier: .gregorian)
//            let now = Date()
//            let scheduleDate = scheduleTime.dateFromTimeTransform
//            
//            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
//            var scheduleComponents = calendar.dateComponents([.hour, .minute], from: scheduleDate!)
//            
//            components.hour = scheduleComponents.hour
//            components.minute = scheduleComponents.minute
//            components.second = 0
//            
//            let date = calendar.date(from: components)!
//            
//            activity.ScheduleDate = date
//        }
//        
//        if let aps = userInfo["aps"] as? NSDictionary{
//            if let alert = aps["alert"] as? NSDictionary{
//                if let title = alert["title"] as? String{
//                    if let body = alert["body"] as? String{
//                        if activity.UserMedicationId != nil{
//                            if let medication = userInfo["Medication"] as? String{
//                                if let instructions = userInfo["Instructions"] as? String{
//                                    if KeychainManager.sharedManager.getIsLoggedIn(){
//                                        showActivityDialog(animated: true, title: medication, message: instructions, activity: activity)
//                                    }
//                                }
//                            }
//                        }else{
//                            showNotificationDialog(title: title, message: body)
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    func processRemoteNotification(userInfo: [AnyHashable : Any]){
        var sectionType: Int?
        if let section = userInfo["Section"] as? String{
            sectionType = Int(section)
        }
        
        if let aps = userInfo["aps"] as? NSDictionary{
            if let alert = aps["alert"] as? NSDictionary{
                if let title = alert["title"] as? String{
                    if let body = alert["body"] as? String{
                        if sectionType != nil{
                            if KeychainManager.sharedManager.getIsLoggedIn(){
                                if remoteNotifications.count > 0{
                                    remoteNotifications.removeObject(at: 0)
                                }
                                showActivityDialog(animated: true, title: title, message: body, section: sectionType!)
                            }
                        }else{
                            showNotificationDialog(title: title, message: body)
                        }
                    }
                }
            }
        }
    }
    
    func showNotificationDialog(animated: Bool = true, title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { (action) in
            NotificationManager.sharedManager.getNextNotification()
        }
        alertController.addAction(dismissAction)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.window?.rootViewController?.present(alertController, animated: animated, completion: nil)
    }
    
    func showVersionNotificationDialog(animated: Bool = true){
        let alertDialog = UIAlertController(title: "New Update Available", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Update", style: .destructive) { (action) in
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/us/app/apple-store/id1285348991?mt=8")!)
        }
        alertDialog.addAction(action)
        getCurrentViewController()?.present(alertDialog, animated: animated, completion: nil)
    }
    
    func showPersonalizerSurveyDialog(animated: Bool = true, controller: HomeMenuViewController){
        let alertController = UIAlertController(title: "Take Personalized Survey", message: "", preferredStyle: .alert)
        let takeAction = UIAlertAction(title: "Take Survey", style: .default) { (action) in
            controller.getItem(itemId: 2, completion: { (vc, item) in
                if vc != nil{
                    Globals.baseVC = controller
                    controller.show(vc!, sender: controller)
                }
            })
        }
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { (action) in
        }
        alertController.addAction(dismissAction)
        alertController.addAction(takeAction)
        controller.present(alertController, animated: animated, completion: nil)
    }
//    func showActivityDialog(animated: Bool = true, title: String, message: String, activity: MedicationActivity){
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        let dismissAction = UIAlertAction(title: "Snooze", style: .destructive){ (action) in
//            NotificationManager.sharedManager.getNextNotification()
//        }
//        alertController.addAction(dismissAction)
//        let takenAction = UIAlertAction(title: "Taken", style: .default) { (action) in
//            var activities = [MedicationActivity]()
//            activities.append(activity)
//            ApiManager.sharedManager.saveMedicationActivity(activities, completion: { (error) in
//                NotificationManager.sharedManager.getNextNotification()
//            })
//        }
//        alertController.addAction(takenAction)
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        appDelegate?.window?.rootViewController?.present(alertController, animated: animated, completion: nil)
//    }
    
    func showActivityDialog(animated: Bool = true, title: String, message: String, section: Int){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        ApiManager.sharedManager.getMedicationsNotTakenByHour(section) { (medications, error) in
            if medications.count == 0{
                self.emptyMedicationAlert()
            }else{
                let vc = MedicationTakenPopupController()
                vc.medications = medications
                vc.schedulesViewController = nil
                vc.modalPresentationStyle = .custom
                vc.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
                vc.view.superview?.layer.cornerRadius = 5
                appDelegate?.window?.rootViewController?.present(vc, animated: true, completion: nil)
            }
        }

        /*
        ApiManager.sharedManager.getMedicationsNotTaken { (medications, error) in
            let medicationsNotTakenBySection = MedicationNotTakenGroup().groupWithMedicationsBySection(medicationsNotTaken: medications)
            var selectedGroup: MedicationNotTakenGroup?
            for group in medicationsNotTakenBySection{
                if group.section == section{
                    selectedGroup = group
                }
            }
            if selectedGroup != nil{
                if !selectedGroup!.medications.isEmpty{
                    let vc = MedicationTakenPopupController()
                    vc.medications = selectedGroup!.medications
                    vc.schedulesViewController = nil
                    vc.modalPresentationStyle = .custom
                    vc.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
                    vc.view.superview?.layer.cornerRadius = 5
                    appDelegate?.window?.rootViewController?.present(vc, animated: true, completion: nil)
                }else{
                    self.emptyMedicationAlert()
                }
            }else{
                self.emptyMedicationAlert()
            }
        }*/
    }
    
    func emptyMedicationAlert(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let alertController = UIAlertController(title: "No Medications", message: "", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        alertController.addAction(dismissAction)
        appDelegate?.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func getNotifications(){
        if remoteNotifications.count > 0{
            processRemoteNotification(userInfo: remoteNotifications[0] as! [AnyHashable : Any])
        }
    }
    
    func getNextNotification(){
        remoteNotifications.removeObject(at: 0)
        if remoteNotifications.count > 0{
            processRemoteNotification(userInfo: remoteNotifications[0] as! [AnyHashable : Any])
        }
    }
    
    func getCurrentViewController() -> UIViewController?{
        if currentController != nil{
            if currentController?.view.window != nil{//in hierarchy
                return currentController
            }
        }
        
        return UIApplication.shared.keyWindow?.rootViewController
    }
}
