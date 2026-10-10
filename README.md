# APUserAgentGenerator

**APUserAgentGenerator** generates realistic, validated User-Agent strings: browser User-Agents that match what Safari, Chrome, Firefox, Edge and Opera actually send today — including every vendor's frozen and reduced tokens — and RFC 9110 product-form User-Agents for your own app's HTTP traffic.

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Faporat%2FAPUserAgentGenerator%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/aporat/APUserAgentGenerator)
![GitHub Actions Workflow Status](https://github.com/aporat/APUserAgentGenerator/actions/workflows/ci.yml/badge.svg)
[![codecov](https://codecov.io/github/aporat/APUserAgentGenerator/graph/badge.svg?token=OHF9AE0KMC)](https://codecov.io/github/aporat/APUserAgentGenerator)

## Features

- **Five platforms, five browsers** — iOS, macOS, Android, Windows and Linux × Safari, Chrome, Firefox, Edge and Opera. Combinations that do not exist (Safari on Android) throw instead of producing a fake string.
- **Vendor-accurate freezing and reduction** — WebKit's frozen `iPhone OS 18_7` on iOS 26+, `Intel Mac OS X 10_15_7`, `Windows NT 10.0`, Chromium's reduced `Android 10; K` and `Chrome/<major>.0.0.0`, Edge's reduced `Edg/` / `EdgA/`, Firefox's `rv:<major>.0` and Android 10 freeze.
- **Validated input** — versions and device models are checked, so nothing malformed (or a CR/LF header injection) ever reaches the header.
- **App User-Agents** — `MyApp/1.4.2 (iOS 27.0.1; iPhone17,1; build:812)`, auto-detected from the bundle and device, every field overridable or omittable, escaped like CFNetwork.
- **No dependencies, no UIKit, no main actor** — pure Swift + Foundation; builds on every Apple platform and on Linux, and works from any isolation domain.
- **Deterministic by default** — `IOSDevice()` always reports the package's current iOS version; opt into the running device with `IOSDevice.current`.

Every default version lives in [`Sources/UAVersions.swift`](Sources/UAVersions.swift), last verified **2026-10-10** against vendor release feeds (Safari 27, Chrome 156 / iOS 155, Firefox 157, Edge 155, Opera 137, iOS 27.0.1). A scheduled [*Version freshness*](.github/workflows/freshness.yml) workflow re-checks them weekly.

## Requirements

| Platform | Minimum |
|---|---|
| iOS | 17.0 |
| macOS | 14.0 |
| tvOS | 17.0 |
| watchOS | 10.0 |
| visionOS | 1.0 |
| Linux | Swift 6.0 toolchain |

Swift 6.0+ (Xcode 16+). The package compiles in the Swift 6 language mode with complete concurrency checking; every public type is `Sendable`.

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/aporat/APUserAgentGenerator.git", from: "2.0.0")
]
```

Then add `"APUserAgentGenerator"` to your target's dependencies.

## Browser User-Agents: `BrowserUserAgent`

```swift
import APUserAgentGenerator

let ua = try BrowserUserAgent(device: IOSDevice(), browser: SafariBrowser())
print(ua.value)
// Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1

// The same thing, never throws:
BrowserUserAgent.default.value

// Builder style:
let chrome = try BrowserUserAgent.builder()
    .device(WindowsDevice())
    .browser(ChromeBrowser())
    .build()
// Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36
```

`BrowserUserAgent` is a value type: `value` is the header string (also its `description`), and `platform`, `browser` and `browserVersion` (unreduced, after defaults) describe what was built.

### Sample output (current defaults)

| Device | Browser | User-Agent |
|---|---|---|
| `IOSDevice()` | Safari | `Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Mobile/15E148 Safari/604.1` |
| `IOSDevice()` | Chrome | `Mozilla/5.0 (iPhone; CPU iPhone OS 27_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/155.0.8059.37 Mobile/15E148 Safari/604.1` |
| `IOSDevice()` | Firefox | `Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/157.1 Mobile/15E148 Safari/605.1.15` |
| `IOSDevice()` | Edge | `Mozilla/5.0 (iPhone; CPU iPhone OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 EdgiOS/153.4234.46 Mobile/15E148 Safari/605.1.15` |
| `IOSDevice(osVersion: "17.4.1")` | Safari | `Mozilla/5.0 (iPhone; CPU iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1` |
| `MacDevice()` | Safari | `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/27.0 Safari/605.1.15` |
| `MacDevice()` | Firefox | `Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:157.0) Gecko/20100101 Firefox/157.0` |
| `MacDevice()` | Opera | `Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36 OPR/137.0.0.0` |
| `AndroidDevice()` | Chrome | `Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36` |
| `AndroidDevice()` | Edge | `Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Mobile Safari/537.36 EdgA/154.0.0.0` |
| `AndroidDevice()` | Firefox | `Mozilla/5.0 (Android 10; Mobile; rv:157.0) Gecko/157.0 Firefox/157.0` |
| `WindowsDevice()` | Edge | `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36 Edg/155.0.0.0` |
| `LinuxDevice()` | Firefox | `Mozilla/5.0 (X11; Linux x86_64; rv:157.0) Gecko/20100101 Firefox/157.0` |

### Devices

| Device | Platform | Configurable |
|---|---|---|
| `IOSDevice(osVersion: "27.0.1")` | `.iOS` | iOS version (defaults to `UAVersions.iOS`); `IOSDevice.current` reads the running iPhone's version |
| `MacDevice()` | `.macOS` | nothing — every browser reports a frozen macOS version |
| `AndroidDevice(model:osVersion:)` | `.android` | model + Android version (see below) |
| `WindowsDevice()` | `.windows` | nothing — every browser reports `Windows NT 10.0; Win64; x64` |
| `LinuxDevice()` | `.linux` | nothing — every browser reports `X11; Linux x86_64` |

#### iOS: the frozen OS token

On devices running **iOS 26 or later**, WebKit reports `iPhone OS 18_7` instead of the real version, so Safari, Firefox, Edge and Opera on iOS all send it. Chrome for iOS builds its own User-Agent and still sends the real version, always as three components (`27_0_1`, `17_4_0`). On iOS 25 and earlier every browser sends the real version (`17_4_1`). The freeze is decided by the device's iOS version — never by a browser version.

Safari on iOS ships with the OS, so its `Version/` defaults to the device's `<major>.<minor>` and an override must match the device's iOS major version.

#### Android: reduced vs. explicit model

Chrome, Edge and Opera have sent the reduced `Linux; Android 10; K` token since Chrome 110, so that is what `AndroidDevice()` produces (and `osVersion` is ignored). Naming a model opts into the full token:

```swift
try BrowserUserAgent(device: AndroidDevice(model: "Pixel 10 Pro", osVersion: "17"), browser: ChromeBrowser()).value
// Mozilla/5.0 (Linux; Android 17; Pixel 10 Pro) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Mobile Safari/537.36
```

Firefox for Android ignores both and always reports `Android 10; Mobile`.

### Browsers

`SafariBrowser`, `ChromeBrowser`, `FirefoxBrowser`, `EdgeBrowser` and `OperaBrowser` each take an optional `version:` override, given **unreduced** (`"156.0.8078.12"`). The formatter reduces it exactly as the real browser would: `Chrome/156.0.0.0`, `Edg/155.0.0.0`, `Firefox/157.0`; `CriOS/`, `EdgiOS/`, `FxiOS/`, Android `OPR/` and `OPT/` are sent verbatim. Embedded `Chrome/` tokens follow the override: Edge's always equals its own major, and Opera's is derived from the Opera major (or set explicitly with `OperaBrowser(version:chromiumVersion:)`).

`BrowserType.allCases` / `BrowserType.browser`, `UAPlatform.allCases` / `supportedBrowsers` and `UAVersions.defaultVersion(for:on:)` let you iterate over everything that is supported:

| | Safari | Chrome | Firefox | Edge | Opera |
|---|---|---|---|---|---|
| iOS | ✅ | ✅ | ✅ | ✅ | ✅ |
| macOS | ✅ | ✅ | ✅ | ✅ | ✅ |
| Android | — | ✅ | ✅ | ✅ | ✅ |
| Windows | — | ✅ | ✅ | ✅ | ✅ |
| Linux | — | ✅ | ✅ | ✅ | ✅ |

### Errors

Building throws `UserAgentError`:

- `.unsupportedCombination(browser:platform:)` — e.g. Safari on Android.
- `.invalidVersion(field:value:)` — a version that is not 1–4 dot-separated integers (`"27-beta"`, `"27\r\nX: 1"`).
- `.invalidDeviceModel(_:)` — a model with `;`, `(`, `)`, `\`, control or non-ASCII characters, or leading/trailing spaces.
- `.inconsistentVersions(_:)` — e.g. `SafariBrowser(version: "26.0")` on `IOSDevice(osVersion: "17.4")`.

## App User-Agents: `AppUserAgent`

```swift
let ua = try AppUserAgent.builder()
    .addingComment("SDK/3.2")
    .build()
// MyApp/1.4.2 (iOS 27.0.1; iPhone17,1; build:812; SDK/3.2)
```

Format: `Name/Version (System Version; Model; build:Build; comments…)`.

| Field | Auto-detected from | Override | Omit |
|---|---|---|---|
| app name | `CFBundleName` → `CFBundleExecutable` → process name | `.appName(_:)` | — (required) |
| app version | `CFBundleShortVersionString` | `.appVersion(_:)` | `.omitting(.appVersion)` |
| build number | `CFBundleVersion` | `.buildNumber(_:)` | `.omitting(.buildNumber)` |
| system name | compile-time OS (`iOS`, `macOS`, `tvOS`, `watchOS`, `visionOS`, `Linux`) | `.systemName(_:)` | `.omitting(.systemName)` |
| system version | `ProcessInfo.operatingSystemVersion` | `.systemVersion(_:)` | `.omitting(.systemVersion)` |
| device model | `hw.model` (Mac), `uname` machine (`iPhone17,1`), simulated model in the simulator; architecture on Linux | `.deviceModel(_:)` | `.omitting(.deviceModel)` |

```swift
try AppUserAgent.builder()
    .appName("My App")
    .omitting(.deviceModel, .buildNumber)
    .build()
// My%20App/1.4.2 (iOS 27.0.1)
```

Detection uses `Bundle`, `ProcessInfo`, `uname` and `sysctl` only — no UIKit, no `@MainActor` — so it works from any actor, on every Apple platform and on Linux. For deterministic tests, pass your own values: `AppUserAgent.builder(environment: AppEnvironment(appName: "MyApp", appVersion: "1.0"))`.

The system name is the compile-time OS: an iPad reports `iOS` unless you set `.systemName("iPadOS")`.

### Escaping

The product token is percent-encoded the way CFNetwork encodes a bundle name: anything that is not an RFC 9110 token character becomes `%XX` (`My App` → `My%20App`). Every comment part — auto-detected ones included — percent-encodes `(`, `)`, `\`, `;`, `%`, control and non-ASCII characters, so no value can break out of the comment or inject a header. Only an empty app name throws (`UserAgentError.emptyAppName`).

## Migrating from 1.x

2.0 is a breaking release. The string formats for valid input are the same shapes as 1.x except where 1.x was wrong (see the [CHANGELOG](CHANGELOG.md)).

| 1.x | 2.0 |
|---|---|
| `APWebBrowserAgentBuilder.builder().withDevice(d).withBrowser(b).generate()` | `try BrowserUserAgent.builder().device(d).browser(b).build().value` |
| `APWebBrowserAgentBuilder(device: d, browser: b).generate()` | `try BrowserUserAgent(device: d, browser: b).value` |
| `APWebBrowserAgentBuilder.builder().generate()` | `BrowserUserAgent.default.value` |
| `IOSDevice()` (auto-detected the device on iOS) | `IOSDevice.current` — `IOSDevice()` is now always `UAVersions.iOS` |
| `IOSDevice(osVersion: "17.4")` | unchanged |
| `MacDevice(osVersion:)` / `WindowsDevice(osVersion:)` / `LinuxDevice(osVersion:)` | `MacDevice()` / `WindowsDevice()` / `LinuxDevice()` — no browser reports these |
| `AndroidDevice(deviceModel: "Pixel 7")` | `AndroidDevice(model: "Pixel 7")` |
| `AndroidDevice(usesReducedPlatformToken:)` | removed — reduced iff no model |
| `UADevice.deviceModel`, `userAgentSystemInfo(for:)` | `UADevice.platform` (`UAPlatform`), `osVersion`, `model` |
| `UABrowser.browserType`, `version(for:)`, `userAgentPlatformInfo(for:)`, `usesSystemWebKitUserAgent` | `UABrowser.kind`; `version` is the only override; `UAVersions.defaultVersion(for:on:)` / `BrowserUserAgent.browserVersion` for the resolved version |
| `UAVersions.safari`, `.safariMajor`, `.chromeDesktop`, `.edgeDesktop`, `.operaDesktop`, `.operaDesktopChrome`, `.operaAndroidChrome`, `.windowsNT`, `Frozen.iOSFreezeIntroducedInSafari` | `UAVersions.safariMacOS`, `.chrome`, `.edge`, `.opera`, `.operaChromiumOffset`, `.operaAndroidChromiumOffset`, `Frozen.windowsNT`, `Frozen.iOSFreezeMajor` |
| `APAppUserAgentBuilder.builder().withAppName(…).withPlatform(…).withPlatformArchitecture(…).withPlatformVersion(…).withBuildNumber(…).addPart(…).generate()` (`@MainActor`) | `try AppUserAgent.builder().appName(…).systemName(…).deviceModel(…).systemVersion(…).buildNumber(…).addingComment(…).build().value` (any actor) |
| App format `MyApp 1.0 (iOS; arm64; 27.0; B123)` | `MyApp/1.0 (iOS 27.0; iPhone17,1; build:B123)` |
| Invalid input silently sanitized | Browser input throws `UserAgentError`; app input is percent-encoded |
| DeviceKit dependency | none |

If you only want a string and are sure of the inputs, `(try? BrowserUserAgent(device: d, browser: b))?.value` keeps call sites short.

## Keeping versions current

Bump `Sources/UAVersions.swift`, then run `python3 scripts/check-versions.py` (stdlib only) to compare every default with the vendor feeds. The same script runs weekly in CI and fails when a default is two or more majors behind (one for iOS).

## Contributing

Contributions are welcome! Fork, branch, and open a pull request with tests. `swift test` runs the whole suite on macOS or Linux; `swiftlint lint --strict` must pass.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
