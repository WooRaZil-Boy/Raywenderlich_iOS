fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios provision
```
fastlane ios provision
```
Create a code signing certificate and provisioning profile
### ios screenshot
```
fastlane ios screenshot
```
Take screenshots
### ios build
```
fastlane ios build
```
Create ipa
### ios beta
```
fastlane ios beta
```
Upload to TestFlight
### ios upload
```
fastlane ios upload
```
Upload to App Store and submit for review
### ios do_everything
```
fastlane ios do_everything
```
Provision, take screenshots, build and upload to App Store

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
