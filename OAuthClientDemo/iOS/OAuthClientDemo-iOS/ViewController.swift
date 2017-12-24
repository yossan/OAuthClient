//
//  ViewController.swift
//  OAuthClientDemo-iOS
//
//  Created by yoshi-kou on 2017/12/22.
//  Copyright © 2017 ysn551. All rights reserved.
//

import UIKit
import OAuthClient
import Result

let providerInfo = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "provider", ofType: "plist")!)!
let ClientID = providerInfo["client_id"] as! String
let ClientSecret = ""
let RedirectURI = providerInfo["redirect_uri"] as! String

class ViewController: UIViewController {

    lazy var oauthClient: OAuthClient = {
        let provider = Provider.google(withClientId: ClientID, clientSecret: ClientSecret, redirectURI: RedirectURI, scopes: ["https://mail.google.com/"])
        return OAuthClient(provider: provider)
    }()
    
    var result: Result<Token, OAuthClientError>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.result == nil {
            self.showAuthorizationView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showAuthorizationView() {
        let authorizationViewController = self.oauthClient.makeAuthorizationViewController()
        
        authorizationViewController.completionHandler = { [weak authorizationViewController](result) in
            self.result = result
            switch result {
            case .success(let token):
                print(token)
            case .failure(let error):
                print(error)
            }
            authorizationViewController?.dismiss(animated: true, completion: nil)
        }
        
        self.present(authorizationViewController, animated: true, completion: nil)
    }
}

