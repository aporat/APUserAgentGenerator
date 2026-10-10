@testable import APUserAgentGenerator
import Foundation
import Testing

@Suite("Helpers and version constants")
struct HelperTests {

    @Test("NumericVersion formatting")
    func numericVersion() throws {
        let version = try #require(NumericVersion("27.0.1"))
        #expect(version.formatted(separator: "_", minimum: 3, maximum: 3) == "27_0_1")
        #expect(version.formatted(minimum: 4) == "27.0.1.0")
        #expect(version.formatted(maximum: 2) == "27.0")
        #expect(version.reduced == "27.0.0.0")
        #expect(version.majorDotZero == "27.0")
        #expect(try #require(NumericVersion("17")).majorMinor == "17.0")
        #expect(NumericVersion("1.2.3.4.5") == nil)
        #expect(NumericVersion("1.2.3", maxComponents: 2) == nil)
    }

    @Test("Every UAVersions constant parses, so the defaults can never throw")
    func constantsParse() {
        let versions = [
            UAVersions.safariMacOS, UAVersions.chrome, UAVersions.chromeAndroid, UAVersions.chromeIOS,
            UAVersions.firefox, UAVersions.firefoxIOS, UAVersions.edge, UAVersions.edgeAndroid,
            UAVersions.edgeIOS, UAVersions.opera, UAVersions.operaAndroid, UAVersions.operaIOS,
            UAVersions.iOS, UAVersions.android
        ]
        for version in versions {
            #expect(NumericVersion(version) != nil, "\(version)")
        }
        #expect((NumericVersion(UAVersions.iOS)?.major ?? 0) >= UAVersions.Frozen.iOSFreezeMajor)
        #expect(UAVersions.Frozen.iOSVersion == "18_7")
    }

    @Test("Every default resolves for every supported combination")
    func defaultsResolve() {
        for platform in UAPlatform.allCases {
            for kind in BrowserType.allCases where platform.supports(kind) {
                let expectsDefault = !(kind == .safari && platform == .iOS)
                #expect((UAVersions.defaultVersion(for: kind, on: platform) != nil) == expectsDefault)
            }
        }
    }

    @Test("marketingVersion matches UIDevice.systemVersion's shape")
    func marketingVersion() {
        #expect(OperatingSystemVersion(majorVersion: 27, minorVersion: 0, patchVersion: 0).marketingVersion == "27.0")
        #expect(OperatingSystemVersion(majorVersion: 17, minorVersion: 4, patchVersion: 1).marketingVersion == "17.4.1")
    }

    @Test("Descriptions are the raw values")
    func descriptions() {
        #expect(UAPlatform.iOS.description == "iOS")
        #expect(BrowserType.edge.description == "edge")
        #expect(BrowserType.allCases.map(\.browser.kind) == BrowserType.allCases)
    }
}
