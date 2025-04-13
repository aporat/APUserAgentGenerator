# APUserAgentGenerator

**APUserAgentGenerator** is a Swift library designed to generate realistic and customizable User-Agent strings for both browsers and app contexts. It supports mobile and desktop environments, allowing developers to simulate different client configurations for testing, analytics, or other purposes.

[![Swift](https://img.shields.io/badge/Swift-5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS_-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_vision_OS?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/aporat/APUserAgentGenerator/ci.yml?style=flat-square)
[![Codecov](https://img.shields.io/codecov/c/github/aporat/APUserAgentGenerator?style=flat-square)](https://codecov.io/github/aporat/APUserAgentGenerator)

## Features

- Generate realistic User-Agent strings for iOS, macOS, Android, Windows, and Linux
- Supports Safari, Chrome, Firefox, Edge, Opera browsers
- App context support (for analytics SDKs, internal APIs, etc.)
- Builder-style API with version auto-detection and override options
- Built-in random generator for realistic UA sampling

## Installation

### Swift Package Manager

Add the package to your dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/aporat/APUserAgentGenerator.git", from: "1.0.0")
]
```

Then add `"APUserAgentGenerator"` as a dependency to your target.

## Usage

### Browser User-Agent (Default)

Generate a default Safari user-agent based on the current iOS device and OS version:

```swift
let ua = APWebBrowserAgentBuilder.builder().generate()
print(ua)
// Example: Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1
```

### Browser User-Agent (Custom)

Customize browser, platform, and versions:

```swift
let ua = APUserAgentBuilder
    .builder()
    .withDevice(IPhoneDevice())
    .withBrowser(SafariBrowser(version: "18.4"))
    .generate()

print(ua)
// Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1
```



### Random User-Agent

```swift
let randomUA = APUserAgentBuilder.random()
print(randomUA)
// Example: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/... Chrome/... Safari/...
```

### Custom Composition

```swift
let ua = APUserAgentBuilder(
    device: AndroidDevice(osVersion: "13", deviceModel: "Pixel 5"),
    browser: ChromeBrowser(version: "123.0.6312.86")
).generate()

print(ua)
// Mozilla/5.0 (Linux; Android 13; Pixel 5) AppleWebKit/... Chrome/... Safari/...
```



## Contributing

1. Fork this repo
2. Create a new branch
3. Commit and push your changes
4. Open a pull request

Make sure you include tests for any new functionality!



## App User-Agent

Use this to generate a user-agent string for your app or SDK:

```swift
let appUA = APAppUserAgentBuilder
    .builder()
    .withAppName("MyApp")
    .withAppVersion("1.0")
    .withPlatform("iOS")
    .withPlatformArchitecture("arm64")
    .withPlatformVersion("18.4")
    .addPart("SDK/3.2")
    .generate()

print(appUA)
// MyApp 1.0 (iOS; arm64; 18.4; SDK/3.2)
```

## License

MIT — see [LICENSE](LICENSE) file
