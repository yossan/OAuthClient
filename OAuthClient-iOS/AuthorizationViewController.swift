//
//  AuthorizationViewController.swift
//  OAuthClient-iOS
//
//  Created by yoshi-kou on 2017/12/22.
//

import UIKit
import WebKit
import Result

public class AuthorizationViewController: UIViewController {

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var contentView: UIView!
    
    deinit {
        NSLog("\(type(of:self)): \(#function)")
        self.webView.uiDelegate = nil
        self.webView.navigationDelegate = nil
        self.webView.stopLoading()
    }
    
    weak var webView: WKWebView!
    var provider: Provider!
    public var completionHandler: ((Result<Token, OAuthClientError>) -> Void)? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        let webView = WKWebView(frame: self.contentView.bounds)
        
        webView.customUserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
        webView.autoresizingMask = [.flexibleTopMargin, .flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
        
        webView.navigationDelegate = self
        self.contentView.addSubview(webView)
        
        let myRequest = URLRequest(url: self.provider.authorizationURL!)
        webView.load(myRequest)
        self.webView = webView
    }
    
    @IBAction func onCancelBt(_ sender: Any) {
        self.callCompletionWithError(.userCancelled)
    }
}

extension AuthorizationViewController {
    fileprivate func callCompletionWithError(_ error: OAuthClientError) {
        self.callCompletionWithResult(.failure(error))
    }
    
    fileprivate func callCompletionWithToken(_ token: Token) {
        self.callCompletionWithResult(.success(token))
    }
    
    fileprivate func callCompletionWithResult(_ result: Result<Token, OAuthClientError>) {
        DispatchQueue.main.async {
            self.completionHandler?(result)
        }
    }
}

extension AuthorizationViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        if url.scheme == self.provider.redirectURLScheme {
            self.handleRedirectURL(url)
            decisionHandler(.cancel)
            return
        } else if url.scheme != "https" {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.callCompletionWithError(.networkError(error as NSError))
    }
    
    
    // MARK: private methods
    
    private func handleRedirectURL(_ url: URL) {
        switch self.parseRedirectURL(url) {
        case .success(let code):
            self.requestAccessToken(withCode: code)
        case .failure(let error):
            self.callCompletionWithError(error)
        }
    }
    
    private func parseRedirectURL(_ url: URL) -> Result<String, OAuthClientError> {
        let query: [String: String] = url.query?.split(separator: "&").reduce(into: [:]) { (result ,element) in
            let components = element.split(separator: "=").map(String.init)
            guard components.count == 2 else { return }
            result![components[0]] = components[1]
            } ?? [:]
        
        if let code = query["code"] {
            return .success(code)
        } else if let errorCode = query["error"] {
            return .failure(OAuthClientError(errorCode))
        } else {
            return .failure(.unknown)
        }
    }
    
    private func requestAccessToken(withCode ahorizationCode: String) {
        let request = self.provider.makeAccessTokenRequest(withCode: ahorizationCode)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.callCompletionWithError(.networkError(error! as NSError))
                return
            }
            
            self.callCompletionWithResult(self.parseAccessTokenData(data))
        }
        
        task.resume()
    }
    
    private func parseAccessTokenData(_ data: Data?) -> Result<Token, OAuthClientError> {
        guard let data = data,
            let jsonObject = try? JSONSerialization.jsonObject(with: data),
            let info = jsonObject as? [String: Any] else {
                return .failure(.unknown)
        }
        
        if let token = Token(info: info) {
            return .success(token)
        } else if let errorCode = info["error"] as? String {
            let error = OAuthClientError(errorCode, errorDescription: info["error_description"] as? String)
            return .failure(error)
        } else {
            return .failure(.unknown)
        }
    }

}
