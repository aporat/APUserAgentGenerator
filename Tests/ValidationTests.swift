@testable import APUserAgentGenerator
import Testing

@Suite("Input validation and injection")
struct ValidationTests {

    static let badVersions = [
        "", " ", "27-beta", "27.0 ", " 27.0", "27..0", ".27", "27.", "1.2.3.4.5", "x",
        "27\r\nX-Injected: 1", "27\n", "27;", "27)", "２７", "-1", "1e3", "999999999999"
    ]

    @Test("Malformed iOS versions are rejected", arguments: badVersions)
    func badIOSVersion(_ version: String) {
        #expect(throws: UserAgentError.invalidVersion(field: "iOS", value: version)) {
            try BrowserUserAgent(device: IOSDevice(osVersion: version), browser: SafariBrowser())
        }
    }

    @Test("Malformed browser versions are rejected for every browser", arguments: badVersions)
    func badBrowserVersion(_ version: String) {
        let browsers: [any UABrowser] = [
            ChromeBrowser(version: version), FirefoxBrowser(version: version),
            EdgeBrowser(version: version), OperaBrowser(version: version)
        ]
        for browser in browsers {
            #expect(throws: UserAgentError.self) {
                try BrowserUserAgent(device: WindowsDevice(), browser: browser)
            }
            #expect(throws: UserAgentError.self) {
                try BrowserUserAgent(device: IOSDevice(), browser: browser)
            }
        }
        #expect(throws: UserAgentError.self) {
            try BrowserUserAgent(device: MacDevice(), browser: SafariBrowser(version: version))
        }
        #expect(throws: UserAgentError.self) {
            try BrowserUserAgent(device: LinuxDevice(), browser: OperaBrowser(chromiumVersion: version))
        }
    }

    @Test("Malformed Android versions are rejected, with or without a model", arguments: badVersions)
    func badAndroidVersion(_ version: String) {
        #expect(throws: UserAgentError.invalidVersion(field: "Android", value: version)) {
            try BrowserUserAgent(device: AndroidDevice(osVersion: version), browser: ChromeBrowser())
        }
        #expect(throws: UserAgentError.invalidVersion(field: "Android", value: version)) {
            try BrowserUserAgent(device: AndroidDevice(model: "Pixel 9", osVersion: version), browser: ChromeBrowser())
        }
    }

    @Test("Device models that could escape the comment are rejected", arguments: [
        "", " Pixel", "Pixel ", "Pixel; Evil", "Pixel)", "(Pixel", "Pixel\\", "Pixel\r\nX: 1", "Pixel\t9", "Pixél"
    ])
    func badModel(_ model: String) {
        #expect(throws: UserAgentError.invalidDeviceModel(model)) {
            try BrowserUserAgent(device: AndroidDevice(model: model), browser: ChromeBrowser())
        }
    }

    @Test("Ordinary device models are accepted", arguments: ["Pixel 10 Pro", "SM-S938B", "moto g stylus 5G", "CPH2581/EEA"])
    func goodModel(_ model: String) throws {
        #expect(try BrowserUserAgent(device: AndroidDevice(model: model), browser: EdgeBrowser()).value.contains("; \(model))"))
    }

    @Test("Safari on iOS must match the device's iOS major version")
    func safariMismatch() throws {
        #expect(throws: UserAgentError.self) {
            try BrowserUserAgent(device: IOSDevice(osVersion: "17.4"), browser: SafariBrowser(version: "26.0"))
        }
        #expect(try BrowserUserAgent(device: IOSDevice(osVersion: "17.4.1"), browser: SafariBrowser(version: "17.4.1"))
            .value.contains("iPhone OS 17_4_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4.1 Mobile"))
    }

    @Test("A nil osVersion on a custom iOS device falls back to the default")
    func nilIOSVersion() throws {
        var device = IOSDevice()
        device.osVersion = nil
        #expect(try BrowserUserAgent(device: device, browser: ChromeBrowser()).value.contains("iPhone OS 27_1_0 like"))
    }

    @Test("Errors describe themselves")
    func descriptions() {
        #expect(UserAgentError.unsupportedCombination(browser: .safari, platform: .android).description == "safari does not ship on android")
        #expect(UserAgentError.invalidVersion(field: "iOS", value: "x").description == "Invalid iOS version: \"x\"")
        #expect(UserAgentError.invalidDeviceModel("a;b").description == "Invalid device model: \"a;b\"")
        #expect(UserAgentError.inconsistentVersions("x").description == "Inconsistent versions: x")
        #expect(UserAgentError.emptyAppName.description == "The app name is empty")
    }
}
