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
    }

    override func viewWillAppear() {
        if self.result == nil {
            self.showAthorizationView()
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
        self.showAthorizationView()
    }
    
    @IBAction func onRefreshTokenBt(_ sender: Any) {
        guard case .success(let token)? = self.result else {
            return
        }
        
        self.oauthClient.refreshAccessToken(token) { (result) in
            self.result = result
            switch result {
            case .success(let token):
                self.handleSuccessInFetching(token: token)
            case .failure(let error):
                self.handleFailureInFetchingToken(withError: error)
            }
        }
    }

    // MARK: -
    
    private func showAthorizationView() {
        let athorizationViewController = self.oauthClient.makeAthorizationViewController()
        
        athorizationViewController.completionHandler = { [weak athorizationViewController](result) in
            switch result {
            case .success(let token):
                self.result = .success(token)
                self.handleSuccessInFetching(token: token)
            case .failure(let error):
                self.result = .failure(error)
                self.handleFailureInFetchingToken(withError: error)
            }
            
            athorizationViewController?.dismiss(nil)
        }
        
        self.presentViewControllerAsSheet(athorizationViewController)
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
}
