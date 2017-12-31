//
//  ViewController.swift
//  OAuthClientDemo
//
//  Created by yoshi-kou on 2017/12/10.
//  Copyright © 2017 ysn551. All rights reserved.
//

import Cocoa
import OAuthClient
import Result

let providerInfo = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "provider", ofType: "plist")!)!
let ClientID = providerInfo["client_id"] as! String
let ClientSecret = providerInfo["client_secret"] as! String
let RedirectURI = "http://localhost"

class ViewController: NSViewController {
    
    // MARK: - Instance properties
    
    @IBOutlet weak var failedView: NSView!
    @IBOutlet weak var refreshRequestView: RefreshTokenRequestView!
    
    var result: Result<Token, OAuthClientError>? = nil
    
    // MARK: - Calculating properties
    
    lazy var oauthClient: OAuthClient = {
        let provider = Provider.google(withClientId: ClientID, clientSecret: ClientSecret, redirectURI: RedirectURI, scopes: ["https://mail.google.com/"])
        return OAuthClient(provider: provider)
    }()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let storedToken = self.loadToken() {
            self.result = .success(storedToken)
        }
    }

    override func viewWillAppear() {
        if self.result == nil {
            self.showAuthorizationView()
        } else {
            self.showRefreshTokenView()
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - IB Actions
    
    @IBAction func onReTryBt(_ sender: Any) {
        
        if self.failedView != nil {
            self.failedView.removeFromSuperview()
        }
        self.showAuthorizationView()
    }
    
    @IBAction func onRefreshTokenBt(_ sender: Any) {
        guard case .success(let token)? = self.result else {
            return
        }
        
        self.oauthClient.refreshAccessToken(token) { (result) in
            self.result = result
            switch result {
            case .success(let token):
                self.save(token: token)
                self.handleSuccessInFetching(token: token)
            case .failure(let error):
                self.handleFailureInFetchingToken(withError: error)
            }
        }
    }

    // MARK: -
    
    private func showAuthorizationView() {
        let authorizationViewController = self.oauthClient.makeAuthorizationViewController()
        
        authorizationViewController.completionHandler = { [weak authorizationViewController](result) in
            self.result = result
            switch result {
            case .success(let token):
                self.save(token: token)
                self.handleSuccessInFetching(token: token)
            case .failure(let error):
                self.handleFailureInFetchingToken(withError: error)
            }
            
            authorizationViewController?.dismiss(nil)
        }
        
        self.presentViewControllerAsSheet(authorizationViewController)
    }
    
    private func showAccessTokenFetchFailedView() {
        
        let nib = NSNib.Name("AccessTokenFetchFailedView")
        Bundle.main.loadNibNamed(nib,
                         owner: self, topLevelObjects: nil)
        self.view.addSubview(self.failedView)
    }
    
    private func showRefreshTokenView() {
        let nib = NSNib.Name("RefreshTokenRequestView")
        Bundle.main.loadNibNamed(nib,
                                 owner: self, topLevelObjects: nil)
        self.view.addSubview(self.refreshRequestView)
    }

    private func handleSuccessInFetching(token: Token) {
        self.failedView?.removeFromSuperview()
        if self.refreshRequestView == nil {
            self.showRefreshTokenView()
        }
        self.refreshRequestView.accessTokenLabel.stringValue = token.accessToken
    }
    
    private func handleFailureInFetchingToken(withError error: OAuthClientError) {
        self.refreshRequestView?.removeFromSuperview()
        if self.failedView == nil {
            self.showAccessTokenFetchFailedView()
        }
    }
    
    
    private var storedTokenFileURL: URL {
        let topURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        let appDir = topURL.appendingPathComponent("OAuthClientDemo")
        if FileManager.default.fileExists(atPath: appDir.path) == false {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.appendingPathComponent("authorization.dat")
    }
    
    private func save(token: Token) {
        let encoder = JSONEncoder()
        let data = try? encoder.encode(token)
        if let data = data {
            try? data.write(to: self.storedTokenFileURL)
        }
    }
    
    private func loadToken() -> Token? {
        let decoder = JSONDecoder()
        let data = try? Data(contentsOf: self.storedTokenFileURL)
        if let data = data {
            return try? decoder.decode(Token.self, from: data)
        }
        return nil
    }
}
