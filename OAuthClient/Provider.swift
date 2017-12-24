//
//  Provider.swift
//  OAuth2
//
//  Created by yoshi-kou on 2017/12/09.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

open class Provider {

    let authorizationEndPoint: String
    let accessTokenEndPoint: String
    let redirectURI: String
    
    var authorizationQueries: [String: String]
    var accesstokenQueries:  [String: String]
    var refreshTokenQueries: [String: String]
    
    init(clientId: String,
         clientSecret: String,
         redirectURI: String,
         authorizationEndPoint: String,
         accessTokenEndPoint: String,
         responseType: String,
         scopes: [String]) {
        
        self.authorizationEndPoint = authorizationEndPoint
        self.accessTokenEndPoint = accessTokenEndPoint
        self.redirectURI = redirectURI
    
        self.authorizationQueries = [
            "client_id": clientId,
            "redirect_uri": redirectURI,
            "response_type": responseType,
            "scope": scopes.joined(separator: "")]
        
        self.accesstokenQueries = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "grant_type": "authorization_code"]
        
        self.refreshTokenQueries = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "grant_type": "refresh_token"]
        
    }
    
    public var authorizationURL: URL? {
        var urlcomponents = URLComponents(string: self.authorizationEndPoint)

        urlcomponents?.queryItems = self.authorizationQueries.map { (element)  in
            return URLQueryItem(name: element.key, value: element.value)
        }
        
        return urlcomponents?.url
    }
    
    public func makeAccessTokenRequest(withCode authorizationCode: String) -> URLRequest {
        var request = URLRequest(url: URL(string: self.accessTokenEndPoint)!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestParams: [String] = self.accesstokenQueries.map{ (query) in
            return "\(query.key)=\(query.value)"
        }
        requestParams.append("code=\(authorizationCode)")
        request.httpBody = requestParams.joined(separator: "&").data(using: .utf8)
        return request
    }
    
    public func makeRefreshTokenRequest(withRefreshToken refreshToken: String) -> URLRequest {
        var request = URLRequest(url: URL(string: self.accessTokenEndPoint)!)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        var requestParams: [String] = self.refreshTokenQueries.map { (query) in
            return "\(query.key)=\(query.value)"
        }
        requestParams.append("refresh_token=\(refreshToken)")
        request.httpBody = requestParams.joined(separator: "&").data(using: .utf8)
        return request
    }
    
    lazy var redirectURLHost: String = {
        return URL(string: self.redirectURI)!.host!
    }()

    
    lazy var redirectURLScheme: String = {
        return String(self.redirectURI.prefix(while: { $0 != ":" }))
    }()
}

