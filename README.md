# APUserAgentGenerator

**APUserAgentGenerator** is a Swift library designed to generate realistic and customizable User-Agent strings for various platforms and browsers. It supports mobile and desktop environments, allowing developers to simulate different client configurations for testing, analytics, or other purposes.

[![Swift](https://img.shields.io/badge/Swift-5.9_5.10_6.0-orange?style=flat-square)](https://img.shields.io/badge/Swift-5.9_5.10_6.0-Orange?style=flat-square)
[![Platforms](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_visionOS_-yellowgreen?style=flat-square)](https://img.shields.io/badge/Platforms-macOS_iOS_tvOS_watchOS_vision_OS?style=flat-square)
[![Swift Package Manager](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)](https://img.shields.io/badge/Swift_Package_Manager-compatible-orange?style=flat-square)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/aporat/APUserAgentGenerator/ci.yml?style=flat-square)
[![Codecov](https://img.shields.io/codecov/c/github/aporat/APUserAgentGenerator?style=flat-square)](https://codecov.io/github/aporat/APUserAgentGenerator)

## Features

- **Platform Support**: Generate User-Agent strings for iOS, macOS, Android, and Windows.
- **Browser Support**: Customize User-Agent strings for Safari, Chrome, and Firefox.
- **Dynamic Versioning**: Automatically detects and incorporates system and browser versions.
- **Device Modeling**: Simulate different device models for more accurate User-Agent strings.
- **Extensible Architecture**: Easily extend support for additional platforms or browsers.

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

### Importing the Library

```swift
import APUserAgentGenerator
```

### Generating a User-Agent String

Create an instance of `APBrowserUserAgentGenerator` and configure it as needed:

```swift
let generator = APBrowserUserAgentGenerator(browser: .safari, platform: .iOS)
generator.browserVersion = "17.0"
generator.osVersion = "17.4"
generator.deviceModel = "iPhone14,2"

let userAgent = generator.generate()
print(userAgent)
// Output: Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1
```

### Supported Browsers

- `.safari`
- `.chrome`
- `.firefox`

### Supported Platforms

- `.iOS`
- `.macOS`
- `.android`
- `.windows`

## Customization

You can customize the generated User-Agent string by setting the following properties:

- `browserVersion`: Specifies the browser version.
- `osVersion`: Specifies the operating system version.
- `deviceModel`: Specifies the device model.

If these properties are not set, the generator will attempt to use default values based on the current system.

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
