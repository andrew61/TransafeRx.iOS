//
//  HomeMenuViewController.swift
//  TransafeRx
//
//  Created by Tachl on 8/18/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation

class HomeMenuViewController: UIViewController{
    
    let bottomBarView = BottomBarView.instanceFromNib() as! BottomBarView
    
    var admissionType: Int?
    var isAdmin: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        navigationItem.setHidesBackButton(true, animated: false)
        KeychainManager.sharedManager.setIsLoggedIn(loggedIn: true)
        NotificationManager.sharedManager.currentController = self
        ApiManager.sharedManager.getPersonalizedSurveyTaken { (isTaken, error) in
            if !isTaken && error == nil && NotificationManager.sharedManager.remoteNotifications.count == 0{
                NotificationManager.sharedManager.showPersonalizerSurveyDialog(animated: true, controller: self)
            }else{
                NotificationManager.sharedManager.getNotifications()
            }
        }
        
        let profileBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        profileBtn.setImage(UIImage(named: "profile"), for: .normal)
        profileBtn.addTarget(self, action: #selector(profileAction), for: .touchUpInside)
        let profileBarButton = UIBarButtonItem(customView: profileBtn)
        navigationItem.leftBarButtonItem = profileBarButton
        
        tableView.dataSource = self
        tableView.delegate = self
        
        ApiManager.sharedManager.getIsAdmin { (isAdmin, error) in
            self.isAdmin = isAdmin
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Home"
        
        if !ReachManager.shared.connectedToNetwork(){
            ReachManager.shared.showConnectionAlert(vc: self)
        }
        
        NotificationManager.sharedManager.getNotifications()
        
        ApiManager.sharedManager.getAdmission { (type, error) in
            if type != nil && error == nil{
                self.admissionType = type
            }
            self.bottomBarView.frame = CGRect(x: 0, y: self.view.bounds.height - 100, width: self.view.bounds.width, height: 100)
            self.bottomBarView.setData(type: self.admissionType)
            self.bottomBarView.bottomBarViewDelegate = self
            self.view.addSubview(self.bottomBarView)
            self.bottomBarView.reloadData()
        }

        return
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DBManager.sharedManager.transmitBloodPressures()
        DBManager.sharedManager.transmitBloodGlucoses()
        return
    }
    
    override func viewWillDisappear(_ animated: Bool){
        return
    }
    
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    
    @objc func profileAction(){
        let vc = storyboard?.instantiateViewController(withIdentifier: "MyInformationViewController") as! MyInformationViewController
        show(vc, sender: self)
    }
    
    func admissionAction(){
        let alertController = UIAlertController(title: "Hospital Admission?", message: "Have you been admitted to a hospital?", preferredStyle: .alert)
        let dischargeAction = UIAlertAction(title: "YES", style: .default) { (action) in
            ApiManager.sharedManager.saveAdmission(completion: { (error) in
                if error == nil{
                    self.admissionType = 1
                    self.bottomBarView.setData(type: self.admissionType)
                    self.bottomBarView.reloadData()
                }
            })
        }
        let dismissAction = UIAlertAction(title: "NO", style: .destructive, handler: nil)
        alertController.addAction(dischargeAction)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func dischargeAction(){
        let alertController = UIAlertController(title: "Hospital Discharge?", message: "Have you been discharged from the hospital?", preferredStyle: .alert)
        let dischargeAction = UIAlertAction(title: "YES", style: .default) { (action) in
            ApiManager.sharedManager.saveDischarge(completion: { (error) in
                if error == nil{
                    self.admissionType = 2
                    self.bottomBarView.setData(type: self.admissionType)
                    self.bottomBarView.reloadData()
                }
            })
        }
        let dismissAction = UIAlertAction(title: "NO", style: .destructive, handler: nil)
        alertController.addAction(dischargeAction)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func visitERAction(){
        let alertController = UIAlertController(title: "Visited the ER?", message: "Have you visited the ER Recently?", preferredStyle: .alert)
        let dischargeAction = UIAlertAction(title: "YES", style: .default) { (action) in
            ApiManager.sharedManager.saveVisit(completion: { (error) in
            })
        }
        let dismissAction = UIAlertAction(title: "NO", style: .destructive, handler: nil)
        alertController.addAction(dischargeAction)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func medicationAction(){
        let alertController = UIAlertController(title: "Medication Change?", message: "Do you have a new medication or change in medication?", preferredStyle: .alert)
        let dischargeAction = UIAlertAction(title: "YES", style: .default) { (action) in
            ApiManager.sharedManager.saveMedicationChange { (error) in
                
            }
        }
        let dismissAction = UIAlertAction(title: "NO", style: .destructive, handler: nil)
        alertController.addAction(dischargeAction)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func getItem(itemId: Int, completion: @escaping (UIViewController?, Item?) -> ()) {
        self.showProgress()
        ApiManager.sharedManager.getItem(itemId) { (item) in
            if item != nil {
                self.getItem(item: item!, completion: { (vc, item) in
                    self.dismissProgress()
                    completion(vc, item)
                })
            }
            else {
                self.dismissProgress()
                completion(nil, nil)
            }
        }
    }
    
    override func getItem(item: NSDictionary, completion: @escaping (UIViewController?, Item?) -> ()) {
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
}

//MARK: - UITableViewDelegate - UITableViewDatasource
extension HomeMenuViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isAdmin{
            return 5
        }else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        switch(indexPath.row){
        case 0:
            cell.menuLabel.text = "Medications"
            break
        case 1:
            cell.menuLabel.text = "Blood Pressure"
            break
        case 2:
            cell.menuLabel.text = "Blood Glucose"
            break
        case 3:
            cell.menuLabel.text = "Side Effects?"
            break
        case 4:
            cell.menuLabel.text = "Clear Data"
            break
        default: break
        }
        
        return cell
    }
}

extension HomeMenuViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            let vc = storyboard?.instantiateViewController(withIdentifier: "MedicationsTabBarViewController") as! MedicationsTabBarViewController
            show(vc, sender: self)
        case 1:
            let vc = storyboard?.instantiateViewController(withIdentifier: "BloodPressureTabBarViewController") as! UITabBarController
            show(vc, sender: self)
        case 2:
            let vc = storyboard?.instantiateViewController(withIdentifier: "BloodGlucoseTabBarViewController") as! UITabBarController
            show(vc, sender: self)
        case 3:
            self.getItem(itemId: 1, completion: { (vc, item) in
                if vc != nil{
                    Globals.baseVC = self
                    self.show(vc!, sender: self)
                }
            })
        case 4:
            let vc = storyboard?.instantiateViewController(withIdentifier: "BloodPressureClearViewController") as! BloodPressureClearViewController
            show(vc, sender: self)
            break
        default:break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
}

//MARK: - BottomBarViewDelegate
extension HomeMenuViewController: BottomBarViewDelegate{
    func selectedCell(index: Int) {
        switch(index){
        case 0: medicationAction()
        case 1:
            if self.admissionType == nil || self.admissionType == 2{
                admissionAction()
            }else{
                dischargeAction()
            }
        case 2: visitERAction()
        default: break
        }
    }
}
