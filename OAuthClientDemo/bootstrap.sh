#!/bin/bash

# Creating OAuthClientDemo-macOS/provider.plist
/usr/libexec/PlistBuddy -c "Add :client_id string " ./macOS/OAuthClientDemo/provider.plist
/usr/libexec/PlistBuddy -c "Add :client_secret string " ./macOS/OAuthClientDemo/provider.plist

# Creating OAuthClientDemo-iOS/provider.plist
/usr/libexec/PlistBuddy -c "Add :client_id string " ./iOS/OAuthClientDemo-iOS/provider.plist
/usr/libexec/PlistBuddy -c "Add :redirect_uri string " ./iOS/OAuthClientDemo-iOS/provider.plist
