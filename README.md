# OAuthClient

This laibrary is OAuth 2.0 client on macOS and iOS.

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

## The problem prohibiting Inner webview in iOS by Google

Google prohibits athorization using inner webview.
As a soluthion to that, this library sets custom useragent to webview. [stackoverflow](https://stackoverflow.com/questions/40591090/403-error-thats-an-error-error-disallowed-useragent)

```OAuthClient-iOS/AthorizationViewController.swift
webView.customUserAgent = "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36"
```

At the present time(2017/12/22), I confirm that it works well.

# About Demo

How to use OAuthClientDemo

1. Open ./OAuthClientDemo/OAuthClientDemo.xcworkspace file.

2. Perform bootstrap.sh

   ```
   sh ./bootstrap.sh
   ```

Then do the followings:

## MacOS
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

## iOS
1. Get client_id and redirect_uri from google

   OauthClientDemo explains how to use OAuthClient with Google.
   So you have to get `client_id` and `redirect_uri` from [Google API Dashboad](https://console.developers.google.com/apis/dashboard).
   

2. Add provider.plist file and add the following kesy:
   * client_id
   * redirect_uri + "://"

   Now set the above variables to the value obtained earlier.

3. Run OAuthClientDemo

  ![screen shot 2017-12-22 at 17 35 51](https://user-images.githubusercontent.com/11131732/34291234-ab65441e-e73e-11e7-9280-3d7cc814f9e5.png)
   

# Installation
## Carthage
Add github "ysn551/OAuthClient" to your Cartfile.<br>
Run carthage update .

# Lincense
OAuthClient is released under the MIT license. See [LICENSE](https://github.com/ysn551/OAuthClient/blob/master/LICENSE).
