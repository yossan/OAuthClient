//
//  Token.swift
//  OAuthClient
//
//  Created by yoshi-kou on 2017/12/10.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

public struct Token {
    public private(set) var accessToken: String
    public let refreshToken: String
    public private(set) var expirationDate: Date
    public let tokenType: String
    
    init?(info: [String: Any]) {
        guard
            let accessToken = info["access_token"] as? String,
            let refreshToken = info["refresh_token"] as? String,
            let expiresIn = info["expires_in"] as? Int,
            let tokenType = info["token_type"] as? String else {
                return nil
        }
        
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expirationDate = Date(timeInterval: TimeInterval(expiresIn), since: Date())
    }

    func updated(_ info: [String: Any]) -> Token? {
        guard let accessToken = info["access_token"] as? String,
            let expiresIn = info["expires_in"] as? Int else {
                return nil
        }
        
        var token = self
        token.accessToken = accessToken
        token.expirationDate = Date(timeInterval: TimeInterval(expiresIn), since: Date())
        return token
    }
}
