# APUserAgentGenerator

**APUserAgentGenerator** is a Swift library designed to generate realistic and customizable User-Agent strings for both browsers and app contexts. It supports mobile and desktop environments, allowing developers to simulate different client configurations for testing, analytics, or other purposes.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
![GitHub Actions Workflow Status](https://github.com/aporat/APUserAgentGenerator/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/github/aporat/APUserAgentGenerator/graph/badge.svg?token=OHF9AE0KMC)](https://codecov.io/github/aporat/APUserAgentGenerator)

## Features

- **Platform Support**: Generate User-Agent strings for iOS, macOS, Android, Windows, and Linux.
- **Browser Support**: Supports Safari, Chrome, Firefox, Edge, and Opera.
- **App Context Support**: Easily generate User-Agent strings for apps using bundle and device info.
- **Dynamic Versioning**: Auto-detects or lets you override system and browser versions.
- **Modular Builder Pattern**: Clean, chainable API for flexibility and clarity.

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
// Output: Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1
```

### Customize Example:
```swift
let userAgent = APWebBrowserAgentBuilder
    .builder()
    .withDevice(AndroidDevice(deviceModel: "Pixel 7"))
    .withBrowser(ChromeBrowser(version: "123.0.6312.86"))
    .generate()

print(userAgent)
// Output: Mozilla/5.0 (Linux; Android 14; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Mobile Safari/537.36
```

### Supported Browsers
- `.safari`
- `.chrome`
- `.firefox`
- `.edge`
- `.opera`

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
    .withPlatformVersion("18.4")
    .addPart("SDK/3.2")
    .addPart("Build/567")
    .generate()

print(userAgent)
// Output: MyApp 1.0 (iOS; arm64; 18.4; SDK/3.2; Build/567)
```

### Auto-detection
- App name and version pulled from `Bundle.main`
- Device architecture and OS version pulled from `DeviceKit`

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
