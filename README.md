# OAuthClient

This laibrary is OAuth 2.0 client on Mac.

# Features
This provide the following two functions:
* Obtaining a new access token through a provider's athorization site.
* Refreshing a access token by using refresh token which is saved by you.

Therefore, there is no function to save the token.

## Obtaining a new Access Token

You can obtain a new acccess token through AthorizationViewController.

```OauthClientDemo/ViewController.swift
private func showAthorizationView() {
    let athorizationViewController = self.oauthClient.makeAthorizationViewController()
    

    // Set completionHandler
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
    
    // Show Atorization View
    self.presentViewControllerAsSheet(athorizationViewController)
}
```


## Refreshing a Access Token

You can refresh access token by using the saved refresh token.

```OauthClientDemo/ViewController.swift
self.oauthClient.refreshAccessToken(token) { (result) in
    self.result = result
    switch result {
    case .success(let token):
        self.handleSuccessInFetching(token: token)
    case .failure(let error):
        self.handleFailureInFetchingToken(withError: error)
    }
}
```

# About Demo

How to use OAuthClientDemo

1. Get client_id and client_secret from google

   OauthClientDemo explains how to use OAuthClient with Google.
   So you have to get `client_id` and `client_secret` from [Google API Dashboad](https://console.developers.google.com/apis/dashboard).
   

2. Add provider.plist file and add the following kesy:
   * client_id
   * client_secret

   Now set the above variables to the value obtained earlier.
   
   ![screen shot 2017-12-16 at 17 00 14](https://user-images.githubusercontent.com/11131732/34068870-0880d79c-e287-11e7-84dd-24f78a0f9911.png)


3. Run OAuthClientDemo

![screen shot 2017-12-16 at 17 21 32](https://user-images.githubusercontent.com/11131732/34068872-12a9b662-e287-11e7-9fa2-e0177e34b35d.png)


# Installation
## Carthage
Add github "ysn551/OAuthClient" to your Cartfile.<br>
Run carthage update .

# Lincense
OAuthClient is released under the MIT license. See [LICENSE](https://github.com/ysn551/OAuthClient/blob/master/LICENSE).
