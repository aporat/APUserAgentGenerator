# APUserAgentGenerator

**APUserAgentGenerator** is a Swift library designed to generate realistic and customizable User-Agent strings for both browsers and app contexts. It supports mobile and desktop environments, allowing developers to simulate different client configurations for testing, analytics, or other purposes.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
![GitHub Actions Workflow Status](https://github.com/aporat/APUserAgentGenerator/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/github/aporat/APUserAgentGenerator/graph/badge.svg?token=OHF9AE0KMC)](https://codecov.io/github/aporat/APUserAgentGenerator)

## Features

- **Platform Support**: Generate User-Agent strings for iOS, macOS, Android, Windows, and Linux.
- **Browser Support**: Supports Safari, Chrome, Firefox, Edge, and Opera.
- **Vendor-accurate freezing**: Reproduces the platform tokens browsers actually pin for anti-fingerprinting — Apple's frozen iOS token, `Intel Mac OS X 10_15_7`, Chromium's reduced `Android 10; K`, and Firefox's Android 10 freeze.
- **App Context Support**: Easily generate User-Agent strings for apps using bundle and device info.
- **Dynamic Versioning**: Auto-detects or lets you override system and browser versions.
- **Modular Builder Pattern**: Clean, chainable API for flexibility and clarity.

Every default version number lives in one file, [`Sources/UAVersions.swift`](Sources/UAVersions.swift), last verified **2026-09-20** (Safari 27, Chrome 153, Firefox 156, Edge 153, Opera 136, iOS 27, Android 17).

## Installation

### Swift Package Manager

To integrate `APUserAgentGenerator` into your Swift project using Swift Package Manager, add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/aporat/APUserAgentGenerator.git", from: "1.0.0")
]
```

Then, include `"APUserAgentGenerator"` as a dependency for your target.

## Usage

### Import the Module
```swift
import APUserAgentGenerator
```

---

## Web Browser User-Agent: `APWebBrowserAgentBuilder`

### Default Example:
```swift
let userAgent = APWebBrowserAgentBuilder
    .builder()
    .generate()

print(userAgent)
// Output: Mozilla/5.0 (iPhone; CPU iPhone OS 18_7_8 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1
```

> The OS token reads `18_7_8` on purpose. Since iOS 26 / Safari 26, WebKit reports a pinned iOS 18
> version rather than the real one, and every browser rendering with the system WebKit inherits it.
> Chrome for iOS builds its own User-Agent and is the one iOS browser that still reports the true
> OS version.

### Customize Example:
```swift
let userAgent = APWebBrowserAgentBuilder
    .builder()
    .withDevice(AndroidDevice())
    .withBrowser(ChromeBrowser())
    .generate()

print(userAgent)
// Output: Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36
```

### Android: reduced vs. explicit device

Chromium has sent a reduced platform token (`Android 10; K`) since Chrome 110, so that is the
default. Naming a device model opts back into the full token:

```swift
APWebBrowserAgentBuilder
    .builder()
    .withDevice(AndroidDevice(deviceModel: "Pixel 10 Pro"))
    .withBrowser(ChromeBrowser())
    .generate()
// Mozilla/5.0 (Linux; Android 17; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.8010.49 Mobile Safari/537.36
```

Pass `usesReducedPlatformToken:` explicitly to force either behaviour.

### Supported Browsers
- `.safari`
- `.chrome`
- `.firefox`
- `.edge`
- `.opera`

`BrowserType.browser` builds a default instance of any of them, which is handy for iterating
over `BrowserType.allCases`.

### Supported Platforms
- `.iOS`
- `.macOS`
- `.android`
- `.windows`
- `.linux`

---

## App Context User-Agent: `APAppUserAgentBuilder`

### Example:
```swift
let userAgent = APAppUserAgentBuilder
    .builder()
    .withAppName("MyApp")
    .withAppVersion("1.0")
    .withPlatform("iOS")
    .withPlatformArchitecture("arm64")
    .withPlatformVersion("27.0")
    .addPart("SDK/3.2")
    .addPart("Build/567")
    .generate()

print(userAgent)
// Output: MyApp 1.0 (iOS; arm64; 27.0; SDK/3.2; Build/567)
```

`APAppUserAgentBuilder` requires UIKit (iOS, tvOS, visionOS). `APWebBrowserAgentBuilder` has no
platform dependencies and builds everywhere, macOS included — so `swift test` runs the browser
suite without a simulator.

### Auto-detection
- App name and version pulled from `Bundle.main`
- Device architecture and OS version pulled from `DeviceKit`

### Sanitization
Every field is stripped of control characters, and `;` / `()` are neutralised, so a value taken
from app configuration or a server response cannot break out of the User-Agent or inject an
HTTP header.

---

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes with descriptive messages.
4. Push your branch to your forked repository.
5. Open a pull request detailing your changes.

Please ensure that your code adheres to the existing coding standards and includes appropriate tests.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
