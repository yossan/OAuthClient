//
//  OAuthClientError.swift
//  OAuthClient
//
//  Created by yoshi-kou on 2017/12/10.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Foundation

public enum OAuthClientError: Error {
    case userCancelled
    case accessTokenDenied
    case invalidGrant (String?)
    case invalidScope (String?)
    case invalidRequest (String?)
    case networkError (NSError)
    case unknown
    
    public init(_ error: String, errorDescription: String? = nil) {
        switch error {
        case "access_denied":
            self = .accessTokenDenied
        case "invalid_grant":
            self = .invalidGrant(errorDescription)
        case "invalid_scope":
            self = .invalidScope(errorDescription)
        case "invalid_request":
            self = .invalidRequest(errorDescription)
        default:
            self = .unknown
        }
    }
}

