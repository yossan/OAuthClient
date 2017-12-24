//
//  Client.swift
//  OAuth2
//
//  Created by yoshi-kou on 2017/12/09.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation
#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif
import Result

@objc
public class OAuthClient: NSObject {
    var provider: Provider!
    public init(provider: Provider) {
        self.provider = provider
    }
    
#if os(macOS)
    public func makeAuthorizationViewController() -> AuthorizationViewController {
        let authorizationView = AuthorizationViewController(nibName: NSNib.Name("AuthorizationViewController"), bundle: Bundle(identifier: "jp.ysn551.OAuthClient"))
        authorizationView.provider = self.provider
        return authorizationView
    }
#elseif os(iOS)
    public func makeAuthorizationViewController() -> AuthorizationViewController {
        let authorizationView = AuthorizationViewController(nibName: "AuthorizationViewController", bundle: Bundle(identifier: "jp.ysn551.OAuthClient"))
        authorizationView.provider = self.provider
        return authorizationView
    }
#endif
    
    private var refreshAccessTokenTask: URLSessionDataTask? = nil
    public func refreshAccessToken(_ token: Token, withCompletion completion: @escaping (Result<Token, OAuthClientError>) -> Void) {
        self.cancelRefreshTokenIfNecessary()
        
        let request = self.provider.makeRefreshTokenRequest(withRefreshToken: token.refreshToken)
        self.refreshAccessTokenTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                guard error == nil else {
                    completion(.failure(.networkError(error! as NSError)))
                    return
                }
                
                completion(self.updateToken(token, withData: data))
            }
        }
        self.refreshAccessTokenTask!.resume()
    }
    
    public func cancelRefreshTokenIfNecessary() {
        self.refreshAccessTokenTask?.cancel()
        self.refreshAccessTokenTask = nil
    }
    
    private func updateToken(_ token: Token, withData data: Data?) -> Result<Token, OAuthClientError> {
        guard let data = data,
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let info = jsonObject as? [String: Any] else {
                return .failure(.unknown)
        }
        
        if let newToken = token.updated(info) {
            return .success(newToken)
        } else if let errorCode = info["error"] as? String {
            let error = OAuthClientError(errorCode, errorDescription: info["error_description"] as? String )
            return .failure(error)
        } else {
            return .failure(.unknown)
        }
    }

}

