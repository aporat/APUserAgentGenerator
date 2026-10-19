import Foundation

/// A single place to bump every version token this package emits.
///
/// Versions are stored **unreduced**, exactly as the vendor publishes them, so
/// they can be compared against release feeds. The formatter reduces them to
/// what each browser actually sends (`Chrome/156.0.0.0`, `Firefox/158.0`, …).
///
/// Last verified on **2026-10-19** (see ``lastVerified``) against:
/// * Chrome — `versionhistory.googleapis.com` (stable channel, per platform)
/// * Firefox — `product-details.mozilla.org`; Firefox for iOS — App Store lookup
/// * Edge — `edgeupdates.microsoft.com/api/products` (stable, per platform)
/// * Opera — `get.geo.opera.com/pub/opera/` and the Opera desktop changelog;
///   Opera for iOS — App Store lookup
/// * iOS — `gdmf.apple.com/v2/pmv`
///
/// `scripts/check-versions.py` re-runs those checks; the scheduled
/// *Version freshness* workflow fails when a default falls behind.
public enum UAVersions {

    /// The date the constants below were last checked against vendor feeds.
    public static let lastVerified = "2026-10-19"

    // MARK: - Browsers

    /// Safari on macOS. Safari on iOS has no constant: it ships with the OS, so
    /// its version is derived from the device's iOS version.
    public static let safariMacOS = "27.0"

    /// Chrome stable on desktop (Windows/macOS). Sent reduced: `Chrome/156.0.0.0`.
    public static let chrome = "156.0.8078.36"
    /// Chrome stable on Android. Also sent reduced since Chrome 110.
    public static let chromeAndroid = "156.0.8078.39"
    /// Chrome stable on iOS. `CriOS/` is the one Chrome token that keeps the
    /// full four-part version. iOS ships on its own train.
    public static let chromeIOS = "156.0.8078.33"

    /// Firefox stable (desktop and Android share a version). Sent as
    /// `Firefox/158.0` — Gecko only ever reports `<major>.0`.
    public static let firefox = "158.0"
    /// Firefox for iOS, sent verbatim in `FxiOS/`.
    public static let firefoxIOS = "158.1"

    /// Edge stable on desktop. Sent reduced: `Edg/155.0.0.0`.
    public static let edge = "155.0.4283.62"
    /// Edge stable on Android. Sent reduced: `EdgA/155.0.0.0`.
    public static let edgeAndroid = "155.0.4283.61"
    /// Edge for iOS, sent verbatim in `EdgiOS/`. Edge for iOS drops the
    /// always-zero minor component (`155.0.4283.48` → `155.4283.48`).
    public static let edgeIOS = "155.4283.48"

    /// Opera stable on desktop. Sent reduced: `OPR/137.0.0.0`.
    public static let opera = "137.0.6036.63"
    /// Opera desktop major N is built on Chromium N + 16 (Opera 137 →
    /// Chromium 153, per the Opera 137 changelog). Used to derive the embedded
    /// `Chrome/` token when only the Opera version is overridden.
    public static let operaChromiumOffset = 16
    /// Opera for Android, sent verbatim in `OPR/`.
    public static let operaAndroid = "102.4.5206.90738"
    /// Opera for Android major N is built on roughly Chromium N + 48. Opera does
    /// not publish this mapping, so treat it as an estimate.
    public static let operaAndroidChromiumOffset = 48
    /// Opera for iOS, which still reports itself with the `OPT/` (Opera Touch) token.
    public static let operaIOS = "6.7.3"

    // MARK: - Operating systems

    /// The current iOS release. ``IOSDevice/init(osVersion:)`` defaults to it.
    public static let iOS = "27.1"
    /// The current Android release, used only when an ``AndroidDevice`` names a
    /// model (otherwise the frozen token is sent).
    public static let android = "17"

    // MARK: - Frozen platform tokens

    /// OS tokens that vendors deliberately pin to a historical value.
    public enum Frozen {
        /// WebKit reports `iPhone OS 18_7` instead of the real version on
        /// devices running iOS 26 or later (WebKit's `Quirks` /
        /// `UserAgentIOS`). Applies to every browser that uses the system
        /// WebKit User-Agent — Safari, Edge, Firefox and Opera — but not to
        /// Chrome, which assembles its own.
        public static let iOSVersion = "18_7"

        /// The first iOS major version whose WebKit reports ``iOSVersion``.
        /// The freeze is decided by the *device's* iOS version, not by any
        /// browser version.
        public static let iOSFreezeMajor = 26

        /// Safari, Chrome and Edge have all reported macOS as 10.15.7 since
        /// Safari 15 / Chrome 90, regardless of the real macOS version.
        public static let macOSVersion = "10_15_7"

        /// Firefox uses the dotted, two-component form of the same value.
        public static let macOSVersionDotted = "10.15"

        /// Every browser has reported `Windows NT 10.0` since Windows 10.
        public static let windowsNT = "10.0"

        /// Chrome's reduced Android token (Chrome 110+), also used by Edge and
        /// Opera, and Firefox for Android's frozen OS version (Firefox 122+).
        public static let androidVersion = "10"
        /// The placeholder device model that accompanies ``androidVersion``.
        public static let androidModel = "K"
    }

    // MARK: - Engine tokens

    /// Engine tokens, which are frozen for compatibility and effectively never change.
    public enum Engine {
        public static let webKit = "AppleWebKit/605.1.15 (KHTML, like Gecko)"
        public static let blink = "AppleWebKit/537.36 (KHTML, like Gecko)"
        /// The build token every iOS browser reports.
        public static let iOSBuild = "15E148"
        /// Trailing Safari token for Safari, Chrome and Opera on iOS.
        public static let safariMobile = "Safari/604.1"
        /// Trailing Safari token for Safari on macOS, and for Firefox/Edge on iOS.
        public static let safariDesktop = "Safari/605.1.15"
        /// Trailing Safari token for Chromium browsers.
        public static let safariBlink = "Safari/537.36"
        /// Gecko's frozen build id on desktop.
        public static let geckoTrail = "20100101"
    }

    // MARK: - Defaults

    /// The version a browser of `kind` defaults to on `platform`, unreduced.
    ///
    /// Returns `nil` where the default depends on the device (Safari on iOS
    /// follows the iOS version) or where the browser does not ship.
    public static func defaultVersion(for kind: BrowserType, on platform: UAPlatform) -> String? {
        guard platform.supports(kind) else { return nil }
        switch kind {
        case .safari: return platform == .macOS ? safariMacOS : nil
        case .chrome: return byPlatform(platform, iOS: chromeIOS, android: chromeAndroid, desktop: chrome)
        case .firefox: return byPlatform(platform, iOS: firefoxIOS, android: firefox, desktop: firefox)
        case .edge: return byPlatform(platform, iOS: edgeIOS, android: edgeAndroid, desktop: edge)
        case .opera: return byPlatform(platform, iOS: operaIOS, android: operaAndroid, desktop: opera)
        }
    }

    private static func byPlatform(_ platform: UAPlatform, iOS: String, android: String, desktop: String) -> String {
        switch platform {
        case .iOS: iOS
        case .android: android
        case .macOS, .windows, .linux: desktop
        }
    }
}
