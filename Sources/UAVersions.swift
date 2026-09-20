import Foundation

/// A single place to bump every version token this package emits.
///
/// Values were last verified on **2026-09-20** against vendor release notes and
/// real captured User-Agent strings. When bumping, only this file should change.
///
/// Two conventions matter here:
///
/// * **Reduced versions.** Chromium-based browsers freeze the minor/build/patch
///   fields of the `Chrome/` token to `0.0.0` on desktop (UA reduction, Chrome
///   101+). The full four-part version only survives in `CriOS/`, `Edg/`,
///   `EdgA/` and the `Chrome/` token on Android.
/// * **Frozen platform tokens.** Apple, Google and Mozilla all pin the OS
///   portion of the UA to a historical value for anti-fingerprinting. Those
///   constants live in ``Frozen``.
public enum UAVersions {

    // MARK: - Browsers

    /// Safari 27.0, shipped 2026-09-14 with iOS 27 / macOS 27.
    public static let safari = "27.0"

    /// Major component of ``safari``, used when another browser has to embed a
    /// `Version/` token of its own.
    public static let safariMajor = 27

    /// Chrome 153.0.8010.50 (desktop), reduced for the UA string.
    public static let chromeDesktop = "153.0.0.0"
    /// Chrome 153.0.8010.49 (Android). Android keeps the full version.
    public static let chromeAndroid = "153.0.8010.49"
    /// Chrome 154.0.8037.41 (iOS). iOS ships on a faster train than desktop.
    public static let chromeIOS = "154.0.8037.41"

    /// Firefox 156.0 — desktop, Android and iOS share a version.
    public static let firefox = "156.0"

    /// Edge 153.0.4234.48 (desktop).
    public static let edgeDesktop = "153.0.4234.48"
    /// Edge 153.0.4234.32 (Android).
    public static let edgeAndroid = "153.0.4234.32"
    /// Edge 153.4234.46 (iOS). iOS drops the third component.
    public static let edgeIOS = "153.4234.46"

    /// Opera 136 stable, reduced. Built on Chromium 152.
    public static let operaDesktop = "136.0.0.0"
    /// The `Chrome/` token Opera desktop embeds (Chromium 152).
    public static let operaDesktopChrome = "152.0.0.0"
    /// Opera for Android, reduced.
    public static let operaAndroid = "100.0.0.0"
    /// The `Chrome/` token Opera for Android embeds. Opera mobile lags desktop.
    public static let operaAndroidChrome = "148.0.0.0"
    /// Opera for iOS, which still reports itself with the `OPT/` (Opera Touch) token.
    public static let operaIOS = "6.6.2"

    // MARK: - Operating systems

    /// iOS 27.0, shipped 2026-09-14.
    public static let iOS = "27.0"
    /// Android 17, shipped 2026-06-16.
    public static let android = "17"
    /// Windows has reported `NT 10.0` since Windows 10 and did not change for 11 or 12.
    public static let windowsNT = "10.0"

    // MARK: - Frozen platform tokens

    /// OS tokens that vendors deliberately pin to a historical value.
    public enum Frozen {
        /// WebKit reports this instead of the real iOS version starting with
        /// iOS 26 / Safari 26. It tracks the newest iOS 18 security release,
        /// so it does creep forward — just far more slowly than iOS itself.
        ///
        /// This applies to every browser that renders with the system WebKit
        /// (Safari, Edge, Firefox, Opera on iOS). Chrome for iOS builds its own
        /// UA and still reports the real version — see
        /// ``UABrowser/usesSystemWebKitUserAgent``.
        public static let iOSVersion = "18_7_8"

        /// The Safari major version that introduced the iOS freeze.
        public static let iOSFreezeIntroducedInSafari = 26

        /// Safari, Chrome and Edge have all reported macOS as 10.15.7 since
        /// Safari 15 / Chrome 90, regardless of the real macOS version.
        public static let macOSVersion = "10_15_7"

        /// Firefox uses dotted, two-component form for the same frozen value.
        public static let macOSVersionDotted = "10.15"

        /// Chrome's reduced Android token, in use since Chrome 110. Both the
        /// Android version and the device model are replaced.
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
        /// Trailing Safari token for Safari and Chrome on iOS.
        public static let safariMobile = "Safari/604.1"
        /// Trailing Safari token for Safari on macOS, and for Firefox/Edge on iOS.
        public static let safariDesktop = "Safari/605.1.15"
        /// Trailing Safari token for Chromium browsers.
        public static let safariBlink = "Safari/537.36"
        /// Gecko's frozen build id on desktop.
        public static let geckoTrail = "20100101"
    }
}
