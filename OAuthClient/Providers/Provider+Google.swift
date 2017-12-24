//
//  Provider+Google.swift
//  OAuth2
//
//  Created by yoshi-kou on 2017/12/09.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

public extension Provider {
    static func google(withClientId clientId: String, clientSecret: String, redirectURI: String, scopes: [String]) -> Provider {
        return Provider(
            clientId: clientId,
            clientSecret: clientSecret,
            redirectURI: redirectURI,
            authorizationEndPoint: "https://accounts.google.com/o/oauth2/v2/auth",
            accessTokenEndPoint: "https://www.googleapis.com/oauth2/v4/token",
            responseType: "code",
            scopes: scopes
        )
    }
}
