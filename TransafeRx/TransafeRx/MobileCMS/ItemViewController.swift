//
//  ItemViewController.swift
//  MobileCMS
//
//  Created by Jonathan on 2/7/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import UIKit

protocol ItemNavigationDelegate {
    func layoutForNavigationButton(navigationButton: UIButton)
    func layoutForNavigationTemplate3(navigationView: UIView)
}

protocol AchievementAlertDelegate {
    func achievementAlertDidDismiss()
}

class ItemViewController: UIViewController {
    
    var item = Item()
    var nextItemVC: UIViewController?
    var previousItemVC: UIViewController?
    var itemToolbarItems: [ToolbarItem]?
    var firstPageView: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if self.previousItemVC == nil {
            self.previousItemVC = ItemNavigationController.previousItemVC
        }
    }
    
    func setupToolbar(item: Item) {
        let vc: UIViewController =  self
        
        if item.ToolbarItems.count > 0 {
            self.itemToolbarItems = item.ToolbarItems
            
            var barButtonItems = [UIBarButtonItem]()
            
            for i in (0..<item.ToolbarItems.count) {
                let toolbarItem = item.ToolbarItems[i]
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                
                button.addTarget(self, action: #selector(self.touchToolbarItem(sender:)), for: .touchUpInside)
                button.tag = i
                
                if toolbarItem.Icon != nil {
                    self.getImage(path: toolbarItem.Icon, completion: { (image) in
                        button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
                    })
                }
                else {
                    button.setTitle(toolbarItem.ItemText, for: .normal)
                }
                
                if item.HeaderColor != nil {
                    button.setTitleColor(UIColor(item.HeaderColor!), for: .normal)
                    button.tintColor = UIColor(item.HeaderColor!)
                }
                
                barButtonItems.append(UIBarButtonItem(customView: button))
            }
            
            vc.navigationItem.rightBarButtonItems = barButtonItems
        }
        else {
            vc.navigationItem.rightBarButtonItems = nil
        }
    }
    
    func setupNavigation(item: Item, completion: (() -> ())?) {
        self.getNextItem(item: item) { (vc, item) in
            let sourceVC: UIViewController =  self
            
            if vc != nil && item?.Navigation != nil {
                self.nextItemVC = vc!
                
                if let navigationTemplate = NavigationTemplate(rawValue: item!.Navigation.TemplateId) {
                    switch navigationTemplate {
                    case .Template1:
                        let navigationButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
                        
                        navigationButton.translatesAutoresizingMaskIntoConstraints = false
                        navigationButton.setTitle(item?.Navigation.ButtonText, for: .normal)
                        navigationButton.addTarget(self, action: #selector(self.goToNextItem), for: .touchUpInside)
                        navigationButton.layer.cornerRadius = 5
                        self.view.addSubview(navigationButton)
                        
                        let views = ["navigationButton" : navigationButton]
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[navigationButton]-8-|", options: [], metrics: nil, views: views))
                        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[navigationButton]-8-|", options: [], metrics: nil, views: views))
                        
                        self.view.addConstraint(NSLayoutConstraint(
                            item: navigationButton,
                            attribute: .height,
                            relatedBy: .equal,
                            toItem: nil,
                            attribute: .notAnAttribute,
                            multiplier: 1,
                            constant: 50
                        ))
                        
                        if item?.Navigation.ButtonImage != nil {
                            self.getImage(path: item?.Navigation.ButtonImage, completion: { (image) in
                                navigationButton.setImage(image, for: .normal)
                            })
                        }
                        
                        if item?.Navigation.ButtonColor != nil {
                            navigationButton.setTitleColor(UIColor(item!.Navigation.ButtonColor!), for: .normal)
                        }
                        
                        if item?.Navigation.ButtonBackgroundColor != nil {
                            navigationButton.backgroundColor = UIColor(item!.Navigation.ButtonBackgroundColor!)
                            navigationButton.tintColor = UIColor(item!.Navigation.ButtonColor!)
                        }
                        
                        navigationButton.titleLabel?.font = UIFont.applicationFontFor(id: item!.Navigation.ButtonFontId, size: item!.Navigation.ButtonFontSize)
                        
                        ItemNavigationController.delegate?.layoutForNavigationButton(navigationButton: navigationButton)
                    case .Template2:
                        let navigationButton = UIBarButtonItem(title: item?.Navigation.ButtonText, style: .plain, target: self, action: #selector(self.goToNextItem))
                        
                        if sourceVC.navigationItem.rightBarButtonItems != nil {
                            var barButtonItems = [UIBarButtonItem]()
                            barButtonItems.append(navigationButton)
                            barButtonItems.append(contentsOf: sourceVC.navigationItem.rightBarButtonItems!)
                            sourceVC.navigationItem.rightBarButtonItems = barButtonItems
                        }
                        else {
                            sourceVC.navigationItem.rightBarButtonItem = navigationButton
                        }
                        
                        if item?.Navigation.ButtonImage != nil {
                            self.getImage(path: item?.Navigation.ButtonImage, completion: { (image) in
                                navigationButton.image = image
                            })
                        }
                        
                        if item?.Navigation.ButtonColor != nil {
                            navigationButton.tintColor = UIColor(item!.Navigation.ButtonColor!)
                        }
                        
                        navigationButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.applicationFontFor(id: item!.Navigation.ButtonFontId, size: item!.Navigation.ButtonFontSize), NSAttributedString.Key.foregroundColor: UIColor(item!.Navigation.ButtonColor ?? "")], for: .normal)
                    case .Template3:
                        let navigationView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
                        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        let forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                        
                        navigationView.translatesAutoresizingMaskIntoConstraints = false
                        self.view.addSubview(navigationView)
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[navigationView]|",
                            options: [],
                            metrics: nil,
                            views: ["navigationView" : navigationView]))
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "V:[navigationView]|",
                            options: [],
                            metrics: nil,
                            views: ["navigationView" : navigationView]))
                        
                        backButton.translatesAutoresizingMaskIntoConstraints = false
                        backButton.setImage(UIImage(named: "ic_back_chevron"), for: .normal)
                        backButton.addTarget(self, action: #selector(self.goToPreviousItem), for: .touchUpInside)
                        
                        forwardButton.translatesAutoresizingMaskIntoConstraints = false
                        forwardButton.setImage(UIImage(named: "ic_chevron_right_48pt"), for: .normal)
                        forwardButton.addTarget(self, action: #selector(self.goToNextItem), for: .touchUpInside)
                        
                        navigationView.addSubview(backButton)
                        navigationView.addSubview(forwardButton)
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "H:|[backButton(==50)]",
                            options: [],
                            metrics: nil,
                            views: ["backButton" : backButton]))
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|[backButton]|",
                            options: [],
                            metrics: nil,
                            views: ["backButton" : backButton]))
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "H:[forwardButton(==50)]|",
                            options: [],
                            metrics: nil,
                            views: ["forwardButton" : forwardButton]))
                        
                        self.view.addConstraints(NSLayoutConstraint.constraints(
                            withVisualFormat: "V:|[forwardButton]|",
                            options: [],
                            metrics: nil,
                            views: ["forwardButton" : forwardButton]))
                        
                        if item?.Navigation.ButtonColor != nil {
                            backButton.tintColor = UIColor(item!.Navigation.ButtonColor!)
                            forwardButton.tintColor = UIColor(item!.Navigation.ButtonColor!)
                        }
                        
                        if item?.Navigation.ButtonBackgroundColor != nil {
                            navigationView.backgroundColor = UIColor(item!.Navigation.ButtonBackgroundColor!)
                        }
                        
                        ItemNavigationController.delegate?.layoutForNavigationTemplate3(navigationView: navigationView)
                    }
                }
                
                let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.goToNextItem))
                swipeLeftGesture.direction = .left
                self.view.addGestureRecognizer(swipeLeftGesture)
                
                let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.goToPreviousItem))
                swipeRightGesture.direction = .right
                self.view.addGestureRecognizer(swipeRightGesture)
            }
            
            completion?()
        }
    }
    
    @objc func goToNextItem() {
        if self.nextItemVC != nil {
            self.navigateToVC(vc: self.nextItemVC!)
        }
    }
    
    @objc func goToPreviousItem() {
        if self.previousItemVC != nil {
            _ = self.navigationController?.popToViewController(self.previousItemVC!, animated: true)
        }
    }
    
    @objc func touchToolbarItem(sender: UIButton) {
        let toolbarItem = self.itemToolbarItems?[sender.tag]
        
        if toolbarItem != nil {
            if let toolbarAction = ToolbarAction(rawValue: toolbarItem!.ActionId) {
                switch toolbarAction {
                case .GoToItem:
                    self.getItem(itemId: toolbarItem!.TargetItemId, completion: { (vc, item) in
                        if vc != nil {
                            let navigationVC = UINavigationController(rootViewController: vc!)
                            
                            let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissToolbarItem))
                            vc!.navigationItem.leftBarButtonItem = closeButton
                            
                            self.present(navigationVC, animated: true, completion: nil)
                        }
                    })
                }
            }
        }
    }
    
    @objc func dismissToolbarItem() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func setTheme(item: Item) {
        let vc: UIViewController =  self
        
        let exitBarButtonItem = UIBarButtonItem(title: "Exit", style: .done, target: self, action: #selector(itemExitAction))
        
        vc.navigationItem.leftBarButtonItem = exitBarButtonItem
        
        vc.navigationItem.title = "Survey"//item.HeaderTitle
        //vc.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont.applicationFontFor(id: item.HeaderFontId, size: item.HeaderFontSize), NSForegroundColorAttributeName: UIColor(item.HeaderColor ?? "")]
        
        if item.HeaderColor != nil {
            //vc.navigationController?.navigationBar.tintColor = UIColor(item.HeaderColor!)
            //vc.navigationItem.leftBarButtonItem?.tintColor = UIColor(item.HeaderColor!)
        }
        
        if item.HeaderBackgroundColor != nil {
            //vc.navigationController?.navigationBar.barTintColor = UIColor(item.HeaderBackgroundColor!)
            //vc.navigationController?.navigationBar.backgroundColor = UIColor(item.HeaderBackgroundColor!)
        }
        
        if item.HeaderImage != nil {
            vc.getImage(path: item.HeaderImage, completion: { (image) in
                let headerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
                headerImageView.image = image
                headerImageView.contentMode = .scaleAspectFit
                //vc.navigationItem.titleView = headerImageView
            })
        }
        
        if item.HeaderBackgroundImage != nil {
            vc.getImage(path: item.HeaderBackgroundImage, completion: { (image) in
                if image != nil {
                    //vc.navigationController?.navigationBar.setBackgroundImage(image!.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: .default)
                }
            })
        }
        else {
            //vc.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        }
        
        if item.BodyBackgroundColor != nil {
            vc.view.backgroundColor = UIColor(item.BodyBackgroundColor!)
            
            //            let frame = self.navigationController?.navigationBar.frame
            //            let borderRect = CGRect(x: 0, y: (frame?.height)!, width: (frame?.width)!, height: 1)
            //            let borderView = UIView(frame: borderRect)
            //            borderView.backgroundColor = UIColor(item.BodyBackgroundColor!)
            //            self.navigationController?.navigationBar.addSubview(borderView)
        }
        
        if item.BodyBackgroundImage != nil {
            vc.getImage(path: item.BodyBackgroundImage!, completion: { (image) in
                if image != nil {
                    UIGraphicsBeginImageContext(self.view.frame.size)
                    image!.draw(in: self.view.bounds)
                    
                    if let backgroundImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
                        UIGraphicsEndImageContext()
                        self.view.backgroundColor = UIColor(patternImage: backgroundImage)
                    }
                    else {
                        UIGraphicsEndImageContext()
                    }
                }
            })
        }
    }
    
    @objc func getItem(itemId: Int, completion: @escaping (UIViewController?, Item?) -> ()) {
        ApiManager.sharedManager.getItem(itemId) { (item) in
            if item != nil {
                self.getItem(item: item!, completion: { (vc, item) in
                    completion(vc, item)
                })
            }
            else {
                completion(nil, nil)
            }
        }
    }
    
    @objc public func getItem(item: NSDictionary, completion: @escaping (UIViewController?, Item?) -> ()) {
        let storyboard = self.storyboard ?? UIStoryboard(name: "Main", bundle: nil)
        
        var navigation: ItemNavigation?
        if let navigationJSON = item["Navigation"] as? [String : Any] {
            navigation = ItemNavigation(JSON: navigationJSON)
        }
        
        var toolbarItems = [ToolbarItem]()
        if let json = item["ToolbarItems"] as? [Dictionary<String, AnyObject>] {
            for obj in json {
                let toolbarItem = ToolbarItem(JSON: obj)
                toolbarItems.append(toolbarItem!)
            }
        }
        
        var actions = [ItemAction]()
        if let json = item["Actions"] as? [Dictionary<String, AnyObject>] {
            for obj in json {
                let action = ItemAction(JSON: obj)
                actions.append(action!)
            }
        }
        
        if let itemType = ItemType(rawValue: item["ItemTypeId"] as! Int) {
            switch itemType {
            case .Accordion:break
            case .Agreement:break
            case .Content:break
            case .CustomItem:
                completion(nil, nil)
            case .DialogCards:break
            case .Form:break
            case .MemoryGame:
                completion(nil, nil)
            case .Menu:break
            case .Quiz:break
            case .Resource:break
            case .Survey:
                let survey = Survey(JSON: item["Item"] as! [String : Any])
                survey?.Navigation = navigation
                survey?.ToolbarItems = toolbarItems
                survey?.Actions = actions
                if survey!.AllowRestart && survey!.Session != nil && survey!.Session!.EndDateUTC == nil {
                    let vc = storyboard.instantiateViewController(withIdentifier: "surveyRestartVC") as! SurveyRestartViewController
                    vc.survey = survey!
                    vc.item = survey!
                    completion(vc, survey)
                }
                else {
                    let vc = SurveyViewController()
                    vc.survey = survey!
                    vc.item = survey!
                    vc.getNextQuestion(completion: { (vc) in
                        completion(vc, survey)
                    })
                }
            case .Video:break
            case .Achievement:break
            case .Pager:break
            }
        }
        else {
            completion(nil, nil)
        }
    }
    
    @objc func getNextItem(item: Item?, completion: @escaping (UIViewController?, Item?) -> ()) {
        ApiManager.sharedManager.getNextItem(item?.ItemId) { (nextItem) in
            if nextItem != nil {
                self.getItem(item: nextItem!, completion: { (vc, item) in
                    completion(vc, item)
                })
            }
            else {
                completion(nil, nil)
            }
        }
    }
    
    public func navigate(to vc: UIViewController, navigationTypeId: Int?, transitionTypeId: Int?) {
        if let navigationType = NavigationType(rawValue: navigationTypeId ?? 1) {
            switch navigationType {
            case .Push:
                if self.parent != nil {
                    ItemNavigationController.previousItemVC = self
                    self.show(vc, sender: nil)
                }
                else {
                    ItemNavigationController.previousItemVC = self
                    self.show(vc, sender: nil)
                }
            case .PushNewContext:
                var parentVC = self as UIViewController
                while parentVC.parent != nil{
                    parentVC = parentVC.parent!
                }
                parentVC = (parentVC as? UINavigationController)?.visibleViewController ?? parentVC
                ItemNavigationController.previousItemVC = parentVC
                parentVC.navigationController?.isNavigationBarHidden = false
                parentVC.show(vc, sender: nil)
            case .PushClearContext:
                ItemNavigationController.previousItemVC = nil
                if let appDelegate = UIApplication.shared.delegate {
                    let navigationVC = UINavigationController(rootViewController: vc)
                    appDelegate.window??.rootViewController = navigationVC
                    appDelegate.window??.makeKeyAndVisible()
                }
            case .PopupModal:
                let navigationVC = UINavigationController(rootViewController: vc)
                navigationVC.isNavigationBarHidden = true
                navigationVC.modalPresentationStyle = .custom
                navigationVC.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
                navigationVC.view.superview?.layer.cornerRadius = 5
                self.present(navigationVC, animated: true, completion: nil)
            case .PopupFullScreen:
                let navigationVC = UINavigationController(rootViewController: vc)
                let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissPopover))
                vc.navigationItem.leftBarButtonItem = closeButton
                navigationVC.modalPresentationStyle = .overFullScreen
                self.present(navigationVC, animated: true, completion: nil)
            case .Back:
                var sourceItem: Item?
                var targetVC: UIViewController?
                var viewControllers = [UIViewController]()
                
                if vc is ItemViewController {
                    sourceItem = (vc as! ItemViewController).item
                }
//                else if vc is FormItemViewController {
//                    sourceItem = (vc as! FormItemViewController).item
//                }
                
                if self.navigationController != nil {
                    viewControllers = self.navigationController!.viewControllers
                }
                
                for previousVC in viewControllers {
                    if let itemVC = previousVC as? ItemViewController {
                        if itemVC.item.ItemId == sourceItem?.ItemId {
                            targetVC = previousVC
                            break
                        }
                    }
//                    else if let formVC = previousVC as? FormItemViewController {
//                        if formVC.item.ItemId == sourceItem?.ItemId {
//                            targetVC = previousVC
//                            break
//                        }
//                    }
                }
                
                if targetVC != nil {
                    let index = viewControllers.index(of: targetVC!)
                    
                    if index != nil {
                        viewControllers = Array(viewControllers[0..<index!])
                        ItemNavigationController.previousItemVC = viewControllers.last
                        viewControllers.append(vc)
                        
                        let transition = CATransition()
                        transition.duration = 0.5
                        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                        transition.type = CATransitionType.push
                        transition.subtype = CATransitionSubtype.fromLeft
                        
                        self.navigationController?.view.layer.add(transition, forKey: nil)
                        self.navigationController?.setViewControllers(viewControllers, animated: true)
                    }
                }
            }
        }
        else {
            ItemNavigationController.previousItemVC = self
            self.show(vc, sender: nil)
        }
    }
    
    func navigateToVC(vc: UIViewController) {
        ItemNavigationController.previousItemVC = self
        self.show(vc, sender: nil)
    }
    
    func dismissAchievementAlert() {
        self.dismiss(animated: true) {
            AchievementAlertController.delegate?.achievementAlertDidDismiss()
        }
    }
    
    func getImage(path: String?, completion: @escaping (UIImage?) -> ()) {
        if path == nil {
            completion(nil)
        }
        else {
            ApiManager.sharedManager.getImage(path!, completion: { (image) in
                completion(image)
            })
        }
    }
    
    func performActions(actions: [ItemAction]) {
        for action in actions {
            if let actionType = ItemActionType(rawValue: action.ActionId) {
                switch actionType {
                case .ShowItemModal:
                    self.getItem(itemId: action.TargetItemId, completion: { (vc, item) in
                        if vc != nil {
                            let navigationVC = UINavigationController(rootViewController: vc!)
                            navigationVC.isNavigationBarHidden = true
                            navigationVC.modalPresentationStyle = .custom
                            navigationVC.transitioningDelegate = PopoverTransitioningController.popoverTransitioningDelegate
                            navigationVC.view.superview?.layer.cornerRadius = 5
                            self.present(navigationVC, animated: true, completion: nil)
                        }
                    })
                case .ShowItemFullScreen:
                    self.getItem(itemId: action.TargetItemId, completion: { (vc, item) in
                        if vc != nil {
                            let navigationVC = UINavigationController(rootViewController: vc!)
                            
                            let closeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.dismissPopover))
                            vc!.navigationItem.leftBarButtonItem = closeButton
                            
                            self.present(navigationVC, animated: true, completion: nil)
                        }
                    })
                case .Email:
                    break
                }
            }
        }
    }
    
    @objc func dismissPopover() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func itemExitAction(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "HomeMenuViewController") as! HomeMenuViewController
        show(vc, sender: self)
        //navigationController?.popToViewController(Globals.baseVC!, animated: true)
        //navigationController?.popViewController(animated: true)
    }
}

struct ItemNavigationController {
    static var delegate: ItemNavigationDelegate?
    static var previousItemVC: UIViewController?
    static var menuButton: UIBarButtonItem?
}

struct AchievementAlertController {
    static var delegate: AchievementAlertDelegate?
    static var popoverTransitioningDelegate = PopoverTransitioningDelegate()
}

struct PopoverTransitioningController {
    static var popoverTransitioningDelegate = PopoverTransitioningDelegate()
}
