# Changelog

All notable changes to this project are documented here. The project follows [Semantic Versioning](https://semver.org).

## [2.0.0] - Unreleased

A breaking release that makes every generated string match what the real browser sends, validates all input, and removes the DeviceKit dependency. See **Migrating from 1.x** in the README.

### Breaking changes

- **New value types.** `APWebBrowserAgentBuilder` → `BrowserUserAgent` and `APAppUserAgentBuilder` → `AppUserAgent`. Both are `Sendable`, `Hashable` value types conforming to the new `UserAgent` protocol (`value`, `description`). Builders are `BrowserUserAgent.Builder` (`device(_:)`, `browser(_:)`, `build()`) and `AppUserAgent.Builder`. The old names remain as `unavailable` aliases that point at the replacements.
- **Building throws.** `BrowserUserAgent` throws `UserAgentError` for unsupported browser/platform combinations, malformed versions or device models, and inconsistent versions; `AppUserAgent` throws only for an empty app name. `BrowserUserAgent.default` is a non-throwing shortcut for the defaults.
- **`UAPlatform` enum.** `UADevice` is now `platform` + `osVersion` + `model`; all formatting lives in one place and switches exhaustively over `UAPlatform` × `BrowserType`. `UAPlatform.supportedBrowsers` / `supports(_:)` expose the support matrix.
- **Slimmer protocols.** `UABrowser` is `kind` + `version`; `version(for:)`, `userAgentPlatformInfo(for:)`, `usesSystemWebKitUserAgent`, `browserType`, `UADevice.deviceModel` and `userAgentSystemInfo(for:)` are gone. `UAVersions.defaultVersion(for:on:)` and `BrowserUserAgent.browserVersion` replace `version(for:)`.
- **Deterministic `IOSDevice()`.** It always reports `UAVersions.iOS`; use `IOSDevice.current` (iOS only) for the running device. `IOSDevice(osVersion:)` now takes a non-optional `String`.
- **Devices without knobs.** `MacDevice`, `WindowsDevice` and `LinuxDevice` no longer take `osVersion:` — no browser reports it. `AndroidDevice(deviceModel:osVersion:usesReducedPlatformToken:)` → `AndroidDevice(model:osVersion:)`; the reduced token is used exactly when no model is given.
- **App User-Agent format.** `MyApp 1.0 (iOS; arm64; 27.0; B123)` → RFC 9110 product form `MyApp/1.0 (iOS 27.0; iPhone17,1; build:B123)`. `withPlatform` / `withPlatformArchitecture` / `withPlatformVersion` / `addPart` → `systemName` / `deviceModel` / `systemVersion` / `addingComment`. `platformArchitecture` was really the model identifier and is now named `deviceModel`. Values are percent-encoded instead of having characters stripped.
- **No `@MainActor`.** `AppUserAgent` and `AppEnvironment.current` work from any isolation domain.
- **No DeviceKit.** The package has no dependencies (Dependabot PR #12 for DeviceKit is obsolete).
- **`UAVersions` reorganised.** Versions are stored unreduced. Renamed/removed: `safari`/`safariMajor` → `safariMacOS` (iOS Safari follows the device); `chromeDesktop` → `chrome`; `edgeDesktop` → `edge`; `operaDesktop` → `opera`; `operaDesktopChrome`/`operaAndroidChrome` → `operaChromiumOffset`/`operaAndroidChromiumOffset`; `windowsNT` → `Frozen.windowsNT`; `Frozen.iOSFreezeIntroducedInSafari` → `Frozen.iOSFreezeMajor`. New: `firefoxIOS`, `lastVerified`.
- **Platforms.** Linux is now supported (no UIKit/DeviceKit), alongside iOS 17, macOS 14, tvOS 17, watchOS 10, visionOS 1.

### Fixed

1. The iOS OS-version freeze was decided by the Safari version (default 27), so an iOS 17 device was reported as `18_7_8` by every WebKit browser. It is now decided by the device: iOS 26+ only.
2. The frozen iOS token is `18_7`, not `18_7_8`.
3. Chrome on Android sent its full version; it is reduced to `Chrome/<major>.0.0.0` like every Chromium platform since Chrome 110.
4. iOS versions were truncated to two components. WebKit now sends the full version (`17_4_1`) before the freeze, and Chrome for iOS always sends exactly three (`17_4_0`, `27_0_1`).
5. Every default version was stale. Bumped to the current stable releases verified today (Chrome 156 / Android 156 / iOS 155, Firefox 157 / iOS 157.1, Edge 155 / Android 154 / iOS 153, Opera 137 / Android 102 / iOS 6.7, iOS 27.0.1), and a scheduled **Version freshness** workflow now fails when a default falls behind. Edge desktop and Android now send the reduced `Edg/<major>.0.0.0` / `EdgA/<major>.0.0.0` (per Microsoft's documentation), and Firefox sends `Firefox/<major>.0` even for point-release overrides.
6. Edge's embedded `Chrome/` token fell back to the Safari major (`Chrome/27.0.0.0`) when the Edge version did not parse. Versions are validated now, so there is no fallback.
7. Embedded tokens did not follow overrides: Edge on Android always embedded the default Chrome version, Opera always embedded its default Chromium, and Edge/Opera on iOS embedded the default Safari `Version/` regardless of the device. They now follow the Edge/Opera override and the device's iOS version.
8. Browser input was not validated: a version or Android model containing CR/LF, `;` or `)` went straight into the header. All versions and models are validated and rejected with `UserAgentError`.
9. Impossible combinations (Safari on Android/Windows/Linux) silently returned an iOS Safari string. They throw `.unsupportedCombination`.
10. The app User-Agent was not a valid RFC 9110 product token (`MyApp 1.0`). It is now `MyApp/1.0`, with CFNetwork-style percent-encoding.
11. Auto-detected app fields could not be omitted — passing `nil` meant "auto-detect". `AppUserAgent.Builder.omitting(_:)` removes any of them.
12. Main-actor use was inconsistent: `APAppUserAgentBuilder`'s initializer and `Builder.build()` were `@MainActor` while the rest of the API was not, and `IOSDevice()` read DeviceKit's `UIDevice` from any thread. Nothing is main-actor-bound any more.

### Added

- `UserAgentError`, `UAPlatform`, `UserAgent`, `AppEnvironment` (injectable auto-detection), `OperaBrowser(chromiumVersion:)`, `BrowserUserAgent.default`, `BrowserUserAgent.browserVersion`.
- Golden tests against vendor-published User-Agents (Chromium source, Microsoft Learn, MDN, WebKit), iOS freeze-boundary tests, combination matrix tests and injection tests; the suite runs on macOS, the iOS simulator and Linux.
- CI: pinned Xcode, iOS 17.4 minimum lane, tvOS/watchOS/visionOS build lanes, Linux (Swift 6.0 and 6.4) lane, SwiftLint (`--strict`) lane, Codecov `fail_ci_if_error`, builds on tags, and the scheduled Version freshness workflow (`scripts/check-versions.py`).

### Removed

- DeviceKit, `.ruby-version`, the committed `Package.resolved`, and dead SwiftLint rules (`anyobject_protocol`, `inert_defer`, `unused_private_declaration`, the `identifier_name` config for a disabled rule).

## [1.5.0] and earlier

See the [GitHub releases](https://github.com/aporat/APUserAgentGenerator/releases).
