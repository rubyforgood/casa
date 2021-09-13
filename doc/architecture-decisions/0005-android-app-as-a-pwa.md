# 1. The android app is a [PWA](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps) running in a [TWA](https://developer.chrome.com/docs/android/trusted-web-activity/overview/)

Date: 2021-07-07

## Context

Building a [progressive web app(PWA)](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps) is a very quick way to convert a website into a mobile app for android.
PWAs can support offline mode and push notifications.
Our app runs in a [trusted web activity(TWA)](https://developer.chrome.com/docs/android/trusted-web-activity/overview/) which is very similar to having the web page load in a mobile browser. The trusted web activity offers browser like support for the PWA.

## Consequences
More javascript support for [service workers](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps/Offline_Service_workers) to support offline mode.  
[Maintaining a key for app signing](https://github.com/rubyforgood/casa-android/wiki/How-to-manage-app-signing)
