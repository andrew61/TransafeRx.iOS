//
//  OAuth2Handler.swift
//  VoiceCrisisAlert
//
//  Created by Tachl on 6/6/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

import Foundation
import Alamofire
import KVNProgress
import UIColor_Hex_Swift

class OAuth2Handler: RequestAdapter, RequestRetrier {
    
    private typealias RefreshCompletion = (_ succeeded: Bool, _ accessToken: String?, _ refreshToken: String?) -> Void
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
    }()
    
    private let lock = NSLock()
    
    private var clientID: String
    private var secret: String
    private var baseURLString: String
    private var accessToken: String
    private var refreshToken: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    public init(clientID: String, secret: String, baseURLString: String, accessToken: String, refreshToken: String) {
        self.clientID = clientID
        self.secret = secret
        self.baseURLString = baseURLString
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue("Bearer " + KeychainManager.sharedManager.keychain["access_token"]!, forHTTPHeaderField: "Authorization")
            return urlRequest
        }
        
        return urlRequest
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        lock.lock() ; defer { lock.unlock() }
        
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshTokens { [weak self] succeeded, accessToken, refreshToken in
                    guard let strongSelf = self else { return }
                    
                    strongSelf.lock.lock() ; defer { strongSelf.lock.unlock() }
                    
                    if let accessToken = accessToken, let refreshToken = refreshToken {
                        strongSelf.accessToken = accessToken
                        strongSelf.refreshToken = refreshToken
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                }
            }
        } else {
            completion(false, 0.0)
        }
    }
    
    private func refreshTokens(completion: @escaping RefreshCompletion) {
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let urlString = "\(baseURLString)/token"
        
        let parameters: [String: Any] = [
            "refresh_token": KeychainManager.sharedManager.keychain["refresh_token"]!,
            "client_id": clientID,
            "client_secret": secret,
            "grant_type": "refresh_token"
        ]
        
        showProgress()
        
        sessionManager.request(urlString, method: .post, parameters: parameters)
            .responseJSON { [weak self] response in
                guard let strongSelf = self else { return }
                
                if
                    let json = response.result.value as? [String: Any],
                    let accessToken = json["access_token"] as? String,
                    let refreshToken = json["refresh_token"] as? String
                {
                    KeychainManager.sharedManager.keychain["access_token"] = accessToken
                    KeychainManager.sharedManager.keychain["refresh_token"] = refreshToken
                    self?.dismmissProgress()
                    completion(true, accessToken, refreshToken)
                } else {
                    print("refresh token failed")
                    self?.dismmissProgress()
//                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
//                        appDelegate.popToLogin()
//                    }
                    completion(false, nil, nil)
                }
                
                strongSelf.isRefreshing = false
        }
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
    
    func dismmissProgress(){
        KVNProgress.dismiss()
    }
    
}
