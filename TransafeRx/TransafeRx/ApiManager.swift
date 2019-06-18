//
//  ApiManager.swift
//  VoiceCrisisAlert
//
//  Created by Tachl on 6/6/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import SystemConfiguration
import Foundation
import Alamofire
import CoreTelephony
import ObjectMapper
import KVNProgress
import AVKit
import AVFoundation
import CoreLocation

open class ApiManager{
    
    static let sharedManager = ApiManager()
    
    let delegate = AppDelegate()
    
    let apiBase = "https://tachl.musc.edu/TXP_API"
    let resourceBase = "https://tachl.musc.edu/TXP_API/Resources/"
    let resetBase = "https://tachl.musc.edu/TXP"
    
//    let apiBase = "https://dev-tachl.mdc.musc.edu/TransafeRx_API"
//    let resourceBase = "https://dev-tachl.mdc.musc.edu/TransafeRx_API/Resources/"
//    let resetBase = "https://dev-tachl.mdc.musc.edu/TransafeRx"
    
//    let apiBase = "http://spurstechdev.eastus.cloudapp.azure.com/TransafeRx_API"
//    let resourceBase = "http://spurstechdev.eastus.cloudapp.azure.com/TransafeRx_API/Resources/"
//    let resetBase = "http://spurstechdev.eastus.cloudapp.azure.com/TransafeRx"

    let token_grant = "password"
    let refresh_grant = "refresh_token"
    let client = "TransafeRxiOS"
    let secret = "b49a93b7-7588-44d1-bde4-cd5cae55ebfd"
    
    let sessionManager = SessionManager()
    
    var customConfig = KVNProgressConfiguration()
    
    // MARK: - Initialization
    public init(){
        
    }
    
    // MARK: - Api Methods
    func loginUser(_ username: String, password: String, completion: @escaping (Token) -> ()){
        
        let params = [
            "username":         username,
            "password":         password,
            "grant_type":       token_grant,
            "client_id":        client,
            "client_secret":    secret
        ]
        
        Alamofire.request("\(apiBase)/Token", method: .post, parameters: params)
            .validate()
            .responseJSON{response in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? NSDictionary{
                        let token = Token(JSON: json as! [String : Any])
                        KeychainManager.sharedManager.keychain["access_token"] = token?.AccessToken
                        KeychainManager.sharedManager.keychain["expiration"] = token?.Expires
                        KeychainManager.sharedManager.keychain["refresh_token"] = token?.RefreshToken
                        
                        let oauthHandler = OAuth2Handler (
                            clientID: self.client,
                            secret: self.secret,
                            baseURLString: self.apiBase,
                            accessToken: KeychainManager.sharedManager.keychain["access_token"]!,
                            refreshToken: KeychainManager.sharedManager.keychain["refresh_token"]!)
                        
                        self.sessionManager.adapter = oauthHandler
                        self.sessionManager.retrier = oauthHandler
                        self.transmitLocalStorage()
                        
                        if let apnsToken = KeychainManager.sharedManager.keychain["apns"]{
                            self.saveDeviceToken(DeviceToken(token: apnsToken))
                        }
                        
                        completion(token!)
                    }
                case .failure:
                    print("error login: \(response)")
                    if !self.connectedToNetwork(){
                        self.showConnectionAlert()
                    }
                    completion(Token())
                }
        }
    }
    
    func registerUser(_ username: String, password: String, confirmPassword: String, completion: @escaping (Bool) -> ()){
        
        let params = [
            "email":         username,
            "password":         password,
            "confirmpassword":  confirmPassword
        ]
        
        Alamofire.request("\(apiBase)/api/Register/Account", method: .post, parameters: params)
            .validate()
            .responseJSON{response in
                switch response.result{
                case .success(_):
                    completion(true)
                case .failure:
                    print("error register: \(response)")
                    if !self.connectedToNetwork(){
                        self.showConnectionAlert()
                    }
                    completion(false)
                }
        }
    }
    
    func resetPassword(_ username: String, completion: @escaping (Bool) -> ()){
        
        let params = [
            "email":         username
        ]
        
        Alamofire.request("\(resetBase)/Account/ExternalForgotPassword", method: .post, parameters: params)
            .validate()
            .responseJSON{response in
                switch response.result{
                case .success(_):
                    if let _ = response.result.value as? NSDictionary{
                        completion(true)
                    }
                    completion(false)
                case .failure:
                    print("error resetpassword: \(response)")
                    if !self.connectedToNetwork(){
                        self.showConnectionAlert()
                    }
                    completion(false)
                }
        }
    }
    
    func getAppVersion(completion: @escaping(AppVersion?, Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/AppVersion/AppId/1")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? NSDictionary{
                        let appVersion = AppVersion(JSON: json as! [String : Any])
                        completion(appVersion, nil)
                    }
                    else{
                        completion(nil, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(nil, error)
                }
        }
    }
    
    func getIsAdmin(completion: @escaping(Bool, Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/User/Admin")
            .validate()
            .responseJSON { (response) in
                if let isAdmin = response.result.value as? Bool{
                    completion(isAdmin, response.error)
                }else{
                    completion(false, response.error)
                }
        }
    }
    
    func getPhoneNumbers(completion: @escaping(PhoneNumbers?, Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/User/PhoneNumbers")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? NSDictionary{
                        let phoneNumbers = PhoneNumbers(JSON: json as! [String : Any])
                        completion(phoneNumbers, nil)
                    }
                    else{
                        completion(nil, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(nil, error)
                }
        }
    }
    
    func saveDeviceToken(_ deviceToken: DeviceToken){
        
        let params = Mapper().toJSON(deviceToken)
        
        self.sessionManager.request("\(apiBase)/api/User/APNSToken", method: .post, parameters: params)
            .validate()
            .response { (response) in
                print("deviceTokenReponse: \(response)")
        }
    }
    
    // MARK: - Login Information
    func saveLoginInformation(_ loginInformation: LoginInformation){
        let params = Mapper().toJSON(loginInformation)
        
        self.sessionManager.request("\(apiBase)/api/LoginInformation", method: .post, parameters: params)
            .validate()
            .responseJSON{response in
                switch response.result{
                case .success(_):
                    break
                case .failure(let error):
                    debugPrint(error)
                    break
                }
        }
    }
    
    // MARK: - Personalized Survey Taken
    func getPersonalizedSurveyTaken(_ completion: @escaping(Bool, Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/User/PersonalizedSurveyTaken")
            .validate()
            .responseJSON { (response) in
                if let taken = response.result.value as? Bool{
                    completion(taken, response.error)
                }else{
                    completion(false, response.error)
                }
        }
    }
    
    // MARK: - Blood Pressure
    func getBloodPressureMeasurements(_ completion: @escaping([BloodPressureMeasurement], Error?) -> ()){
        var measurements = [BloodPressureMeasurement]()
        self.sessionManager.request("\(apiBase)/api/BloodPressure")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for obj in json{
                            let measurement = BloodPressureMeasurement(JSON: obj)
                            measurements.append(measurement!)
                        }
                        completion(measurements, nil)
                    }
                    else{
                        completion(measurements, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(measurements, error)
                }
        }
    }
    
    func getBloodPressureMeasurementChart(model: ChartModel, completion: @escaping([BloodPressureMeasurement], Error?) -> ()){
        let params = Mapper().toJSON(model)
        
        var measurements = [BloodPressureMeasurement]()
        self.sessionManager.request("\(apiBase)/api/BloodPressure/Chart", method: .post, parameters: params)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for obj in json{
                            let measurement = BloodPressureMeasurement(JSON: obj)
                            measurements.append(measurement!)
                        }
                        completion(measurements, nil)
                    }
                    else{
                        completion(measurements, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(measurements, error)
                }
        }
    }
    
    func saveBloodPressure(_ bloodPressure: BloodPressureMeasurement, completion: @escaping(Error?) -> ()){
        let params = Mapper().toJSON(bloodPressure)
        
        self.sessionManager.request("\(apiBase)/api/BloodPressure", method: .post, parameters: params)
            .validate()
            .response(completionHandler: { (response) in
                completion(response.error)
            })
    }
    
    // MARK: - Blood Glucose
    func getBloodGlucoseMeasurements(_ completion: @escaping([BloodGlucoseMeasurement], Error?) -> ()){        
        var measurements = [BloodGlucoseMeasurement]()
        self.sessionManager.request("\(apiBase)/api/BloodGlucose")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for obj in json{
                            let measurement = BloodGlucoseMeasurement(JSON: obj)
                            measurements.append(measurement!)
                        }
                        completion(measurements, nil)
                    }
                    else{
                        completion(measurements, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(measurements, error)
                }
        }
    }
    
    func getBloodGlucoseMeasurementChart(model: ChartModel, completion: @escaping([BloodGlucoseMeasurement], Error?) -> ()){
        let params = Mapper().toJSON(model)
        
        var measurements = [BloodGlucoseMeasurement]()
        self.sessionManager.request("\(apiBase)/api/BloodGlucose/Chart", method: .post, parameters: params)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for obj in json{
                            let measurement = BloodGlucoseMeasurement(JSON: obj)
                            measurements.append(measurement!)
                        }
                        completion(measurements, nil)
                    }
                    else{
                        completion(measurements, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(measurements, error)
                }
        }
    }
    
    func saveBloodGlucose(_ bloodGlucose: BloodGlucoseMeasurement, completion: @escaping(Error?) -> ()){
        let params = Mapper().toJSON(bloodGlucose)
        
        self.sessionManager.request("\(apiBase)/api/BloodGlucose", method: .post, parameters: params)
            .validate()
            .response(completionHandler: { (response) in
                completion(response.error)
            })
    }

    // MARK: - UserMedications
    func getUserMedications(completion: @escaping([UserMedication], Error?) -> ()){
        var userMedications = [UserMedication]()
        
        self.sessionManager.request("\(apiBase)/api/UserMedication")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for object in json{
                            let userMedication = UserMedication(JSON: object)
                            
                            userMedications.append(userMedication!)
                        }
                        completion(userMedications, nil)
                    }
                    else{
                        completion(userMedications, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(userMedications, error)
                }
        }
    }
    
    func getMedicationsNotTaken(completion: @escaping([MedicationNotTaken], Error?) -> ()){
        var medications = [MedicationNotTaken]()
        
        self.sessionManager.request("\(apiBase)/api/UserMedication/NotTaken")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for object in json{
                            let medication = MedicationNotTaken(JSON: object)
                            
                            medications.append(medication!)
                        }
                        completion(medications, nil)
                    }
                    else{
                        completion(medications, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(medications, error)
                }
        }
    }
    
    func getMedicationsNotTakenByHour(_ hour: Int, completion: @escaping([MedicationNotTaken], Error?) -> ()){
        var medications = [MedicationNotTaken]()
        
        self.sessionManager.request("\(apiBase)/api/UserMedication/NotTakenHour/\(hour)")
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
                        for object in json{
                            let medication = MedicationNotTaken(JSON: object)
                            
                            medications.append(medication!)
                        }
                        completion(medications, nil)
                    }
                    else{
                        completion(medications, nil)
                    }
                case .failure(let error):
                    debugPrint(error)
                    completion(medications, error)
                }
        }
    }
    
    // MARK: - Medication Activity
    
    func saveMedicationActivity(_ medicationActivity: [MedicationActivity], completion: @escaping(Error?) -> ()){
        
        do{
            var request = try URLRequest(
                url: URL(string: "\(apiBase)/api/MedicationActivity")!,
                method: .post,
                headers: ["Content-Type" : "application/json", "Accept" : "application/json"])
            
            let params = Mapper().toJSONArray(medicationActivity)
            let data = try JSONSerialization.data(withJSONObject: params, options: [])
            
            request.httpBody = data
            
            self.sessionManager.request(request)
                .validate()
                .responseJSON{response in
                    completion(response.error)
            }
        }catch{
            completion(nil)
        }
    }
    
    // MARK: - Admission/Discharge/MedicationChange
    
    func getAdmission(completion: @escaping(Int?, Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/User/Admission", method: .get)
            .validate()
            .responseJSON { (response) in
                switch response.result{
                case .success(_):
                    if let type = response.result.value as? Int?{
                        completion(type, nil)
                    }else{
                        completion(nil, nil)
                    }
                    break
                case .failure(let error):
                    debugPrint(error)
                    completion(nil, error)
                    break
                }
        }
    }
    
    func saveAdmission(completion: @escaping(Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/Email/Admission", method: .post)
            .validate()
            .response { (response) in
                completion(response.error)
        }
    }
    
    func saveDischarge(completion: @escaping(Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/Email/Discharge", method: .post)
            .validate()
            .response { (response) in
                completion(response.error)
        }
    }
    
    func saveVisit(completion: @escaping(Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/Email/Visit", method: .post)
            .validate()
            .response { (response) in
                completion(response.error)
        }
    }

    func saveMedicationChange(completion: @escaping(Error?) -> ()){
        self.sessionManager.request("\(apiBase)/api/Email/Medication", method: .post)
            .validate()
            .response { (response) in
                completion(response.error)
        }
    }
//
//    func getUserMedicationsByMedicationTypeId(_ medicationTypeId: Int, completion: @escaping([UserMedication], Error?) -> ()){
//        var userMedications = [UserMedication]()
//        
//        self.sessionManager.request("\(apiBase)/api/UserMedications/Medications/\(medicationTypeId)")
//            .validate()
//            .responseJSON { (response) in
//                switch response.result{
//                case .success(_):
//                    if let json = response.result.value as? [Dictionary<String, AnyObject>]{
//                        for object in json{
//                            let userMedication = UserMedication(JSON: object)
//                            
//                            userMedications.append(userMedication!)
//                        }
//                        completion(userMedications, nil)
//                    }
//                    else{
//                        completion(userMedications, nil)
//                    }
//                case .failure(let error):
//                    debugPrint(error)
//                    completion(userMedications, error)
//                }
//        }
//    }
//    
//    func saveUserMedication(_ userMedication: UserMedication, completion: @escaping(Error?) -> ()){
//        let params = Mapper().toJSON(userMedication)
//        
//        self.sessionManager.request("\(apiBase)/api/UserMedications", method: .post, parameters: params)
//            .validate()
//            .responseJSON{response in
//                switch response.result{
//                case .success(_):
//                    completion(nil)
//                    break
//                case .failure(let error):
//                    debugPrint(error)
//                    completion(error)
//                    break
//                }
//        }
//    }
//    
//    func deleteUserMedication(_ userMedication: UserMedication, completion: @escaping(Error?) -> ()){
//        let params = Mapper().toJSON(userMedication)
//        
//        self.sessionManager.request("\(apiBase)/api/UserMedications/Delete", method: .post, parameters: params)
//            .validate()
//            .responseJSON{response in
//                switch response.result{
//                case .success(_):
//                    completion(nil)
//                    break
//                case .failure(let error):
//                    debugPrint(error)
//                    completion(error)
//                    break
//                }
//        }
//    }
    
    // MARK: - MOBILE CMS
    func getItem(_ itemId: Int, completion: @escaping (NSDictionary?) -> ()) {
        
        self.sessionManager.request("\(apiBase)/api/Item/\(itemId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? NSDictionary {
                        return completion(json)
                    }
                    else {
                        completion(nil)
                    }
                case .failure( _):
                    completion(nil)
                }
            })
    }
    
    func getNextItem(_ itemId: Int?, completion: @escaping (NSDictionary?) -> ()) {
        
        var id: String? = ""
        
        if itemId != nil {
            id = String(itemId!)
        }
        
        self.sessionManager.request("\(apiBase)/api/Item/Next/\(id!)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? NSDictionary {
                        return completion(json)
                    }
                    else {
                        completion(nil)
                    }
                case .failure(_):
                    completion(nil)
                }
            })
    }
    
    func completeItem(_ itemId: Int, completion: @escaping (Bool) -> ()) {
        
        let params = [
            "itemId": itemId
        ]
        
        self.sessionManager.request("\(apiBase)/api/Item/UserItems/Complete", method: .post, parameters: params)
            .validate()
            .responseString { (response) in
                switch response.result {
                case .success(_):
                    completion(true)
                case .failure( _):
                    completion(false)
                }
        }
    }
    
    func getToolbarItems(_ itemId: Int, completion: @escaping ([ToolbarItem]) -> ()) {
        
        var items = [ToolbarItem]()
        
        self.sessionManager.request("\(apiBase)/api/Item/ToolbarItems/\(itemId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>] {
                        for obj in json {
                            let item = ToolbarItem(JSON: obj)
                            items.append(item!)
                        }
                        completion(items)
                    }
                    else {
                        completion(items)
                    }
                case .failure( _):
                    completion(items)
                }
            })
    }
    
    func getSurvey(_ surveyId: Int, completion: @escaping (Survey?) -> ()) {
        
        self.sessionManager.request("\(apiBase)/api/Item/Survey/\(surveyId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? NSDictionary {
                        let survey = Survey(JSON: json as! [String : Any])
                        completion(survey!)
                    }
                    else {
                        completion(nil)
                    }
                case .failure( _):
                    completion(nil)
                }
            })
    }
    
    func getNextSurveyQuestion(_ surveyId: Int, completion: @escaping (SurveyQuestion?) -> ()) {
        
        self.sessionManager.request("\(apiBase)/api/Item/SurveyQuestion/Next/\(surveyId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? NSDictionary {
                        let question = SurveyQuestion(JSON: json as! [String : Any])
                        completion(question!)
                    }
                    else {
                        completion(nil)
                    }
                case .failure( _):
                    let err = String(data: response.data!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    debugPrint(err)
                    completion(nil)
                }
            })
    }
    
    func getPreviousSurveyQuestion(_ surveyId: Int, _ questionId: Int, completion: @escaping (SurveyQuestion?) -> ()) {
        
        self.sessionManager.request("\(apiBase)/api/Item/SurveyQuestion/Previous/\(surveyId)/\(questionId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? NSDictionary {
                        let question = SurveyQuestion(JSON: json as! [String : Any])
                        completion(question!)
                    }
                    else {
                        completion(nil)
                    }
                case .failure( _):
                    completion(nil)
                }
            })
    }
    
    func getSurveyQuestionOptions(_ questionId: Int, completion: @escaping ([SurveyQuestionOption]) -> ()) {
        
        var options = [SurveyQuestionOption]()
        
        self.sessionManager.request("\(apiBase)/api/Item/SurveyQuestionOptions/\(questionId)")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let json = response.result.value as? [Dictionary<String, AnyObject>] {
                        for obj in json {
                            let option = SurveyQuestionOption(JSON: obj)
                            options.append(option!)
                        }
                    }
                    completion(options)
                case .failure( _):
                    completion(options)
                }
            })
    }
    
    func postSurveyAnswers(_ surveyId: Int, questionId: Int, answers: [SurveyAnswer], completion: @escaping (Bool) -> ()) {
        
        do {
            var request = try URLRequest (
                url: URL(string: "\(apiBase)/api/Item/SurveyAnswers/\(surveyId)/\(questionId)")!,
                method: .post,
                headers: ["Content-Type": "application/json", "Accept": "application/json"]
            )
            
            let json = Mapper().toJSONArray(answers)
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            request.httpBody = data
            
            self.sessionManager.request(request)
                .validate()
                .response { (response) in
                    if response.error == nil {
                        completion(true)
                    }
                    else {
                        completion(false)
                    }
            }
        }
        catch {
            completion(false)
        }
    }
    
    func restartSurvey(_ surveyId: Int, completion: @escaping (Bool) -> ()) {
        self.sessionManager.request("\(apiBase)/api/Item/Survey/\(surveyId)/Restart", method: .post, parameters: nil)
            .validate()
            .responseString { (response) in
                switch response.result {
                case .success(_):
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }

    // MARK: - Misc Methods
    func transmitLocalStorage(){
    }
    
    func getImage(_ path: String, completion:@escaping(UIImage?)->()){
        self.sessionManager.request("\(resourceBase)\(path)")
            .validate()
            .response { (response) in
                if response.data != nil{
                    let image = UIImage(data: response.data!)
                    completion(image)
                }else{
                    completion(nil)
                }
        }
    }

    func getImages(completion: @escaping ([String]?) -> ()) {
        
        self.sessionManager.request("\(apiBase)/api/Images")
            .validate()
            .responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(_):
                    if let images = response.result.value as? [String] {
                        completion(images)
                    }
                    else {
                        completion(nil)
                    }
                case .failure( _):
                    completion(nil)
                }
            })
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func showConnectionAlert(){
        let alertController = UIAlertController(title: "Not Connected to a Network", message:
            "Certain Parts of the App will not Function", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func resizeImage(_ image:UIImage, toTheSize size:CGSize)->UIImage{
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect( x: 0, y: 0, width: width, height: height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
}

// MARK: - Global Variables

// MARK: - Extensions

public extension String{
    func replace(_ string: String, replacement: String) -> String{
        return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil)
    }
    
    func removeWhiteSpace() -> String{
        return self.replace(" ", replacement: "")
    }
}

extension UIViewController{
    func resizeImage(_ image:UIImage, toTheSize size:CGSize)->UIImage{
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect( x: 0, y: 0, width: width, height: height);
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
}

extension Array where Element: Equatable{
    
    mutating func remove(object: Element){
        if let index = index(of: object){
            remove(at: index)
        }
    }
    
    func removeDuplicates() -> [Element]{
        var result = [Element]()
        
        for value in self{
            if result.contains(value) == false{
                result.append(value)
            }
        }
        return result
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension Bool {
    
    func getYesOrNo() -> String{
        if self{
            return "Yes"
        }else{
            return "No"
        }
    }
}
