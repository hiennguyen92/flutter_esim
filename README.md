# Flutter eSIM Plugin

[![pub package](https://img.shields.io/pub/v/flutter_esim.svg)](https://pub.dev/packages/flutter_esim)
[![GitHub stars](https://img.shields.io/github/stars/hiennguyen92/flutter_esim.svg?style=social)](https://github.com/hiennguyen92/flutter_esim/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/hiennguyen92/flutter_esim.svg?style=social)](https://github.com/hiennguyen92/flutter_esim/network)
[![GitHub issues](https://img.shields.io/github/issues/hiennguyen92/flutter_esim.svg)](https://github.com/hiennguyen92/flutter_esim/issues)
[![GitHub license](https://img.shields.io/github/license/hiennguyen92/flutter_esim.svg)](https://github.com/hiennguyen92/flutter_esim/blob/master/LICENSE)

A Flutter plugin for checking eSIM support and installing eSIM profiles directly within your app.

## Table of Contents

- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Example](#example)
- [API Reference](#api-reference)
- [Contributing](#contributing)
- [License](#license)

## Getting Started

To use this plugin, add `flutter_esim` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  flutter_esim: ^latest_version
```

Then, run the command:

```
flutter pub get
```

## Installation
Make sure to follow the platform-specific setup for your project:

Android: No additional setup required.</br>
iOS: No additional setup required.

## Usage
Import the library in your Dart file:
```
import 'package:flutter_esim/flutter_esim.dart';
```

Now you can use the FlutterEsim class to check eSIM support and install eSIM profiles.

```
// Check if the device supports eSIM
// Does not require requesting entitlement approval from Apple (Manual checking)
bool isEsimSupported = await FlutterEsim.isEsimSupported();

// Check if the device supports eSIM
// Does not require requesting entitlement approval from Apple (Manual checking)
// You can add some devices that are not yet on the market that you want to check
List<String> newer = ['iPhone18,4', 'iPhone19,4']
bool isEsimSupported = await FlutterEsim.isEsimSupported(newer);

// Install an eSIM profile
// Require requesting entitlement approval from Apple
bool installedSuccessfully = await FlutterEsim.installEsimProfile(profileData);

// A piece of text containing simple steps for setting up eSIM.
bool textInstructions = await FlutterEsim.instructions();

```

### eSIM Integration Guidelines for iOS

#### Compatibility Check:

You can integrate eSIM functionality into your iOS app by following the steps below. Please note that the process involves requesting entitlement approval from Apple.
https://developer.apple.com//contact/request/esim-access-entitlement

#### Steps:

##### Step 1: Request eSIM Entitlement

Using your developer account, submit a request for the eSIM entitlement through the Apple Developer portal.

##### Step 2: Approval Process

Apple will review and approve the entitlement request. You can check the status of the approval in your app's profile settings.

##### Step 3: Download Profiles

Download the App Development and Distribution profiles. Ensure that the eSIM entitlement is selected as part of Step #2 in the profile settings.

##### Step 4: Update Info.plist

Update your Info.plist file with the following keys and values:

```xml
<key>CarrierDescriptors</key>
<array>
  <dict>
    <key>GID1</key>
    <string>***</string>
    <key>GID2</key>
    <string>***</string>
    <key>MCC</key> <!-- Country Code -->
    <string>***</string>
    <key>MNC</key> <!-- Network Code -->
    <string>***</string>
  </dict>
</array>
```

Note: You can obtain GID1, GID2, MCC, and MNC information for eSIM compatibility from various sources:

* Mobile Network Operators: Contact your mobile network operator for specific eSIM card details.
* Online eSIM Providers: Many providers such as Truphone, Twilio, and Unlocator publish this information on their websites.
* Device Manufacturers: Some manufacturers like Apple and Samsung provide details on their websites or in user manuals.
* eSIM Databases: Websites like esimdb.com offer information on eSIM cards and associated codes.
It's crucial to acknowledge that eSIM compatibility may vary based on the mobile network operator and device. Therefore, always refer to the specific provider or manufacturer for accurate and up-to-date information.





For more details, refer to the <a href="https://pub.dev/documentation/flutter_esim/latest">API Reference</a> section.

## Example
Check out the <a href="https://github.com/hiennguyen92/flutter_esim/tree/main/example">example</a> directory for a simple Flutter app demonstrating the usage of this plugin.

## Contributing
Feel free to contribute to this project!

## License
This project is licensed under the <a href="https://github.com/hiennguyen92/flutter_esim/blob/main/LICENSE">MIT License</a>.