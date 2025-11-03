import XCTest
@testable import APUserAgentGenerator

final class APWebBrowserAgentBuilderTests: XCTestCase {
    
    func testDefault() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1"
        XCTAssertEqual(ua, expected)
    }
    
    func testSafariOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice(osVersion: "18.4"))
            .withBrowser(SafariBrowser(version: "18.4"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1"
        XCTAssertEqual(ua, expected)
    }
    
    func testChromeOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice())
            .withBrowser(ChromeBrowser())
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7526.93 Mobile/15E148 Safari/604.1"
        XCTAssertEqual(ua, expected)
    }
    
    func testChromeOnAndroid() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice(deviceModel: "Pixel 7"))
            .withBrowser(ChromeBrowser(version: "123.0.6312.86"))
            .generate()
        
        let expected = "Mozilla/5.0 (Linux; Android 16; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Mobile Safari/537.36"
        XCTAssertEqual(ua, expected)
    }
    
    func testChromeOnLinux() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(LinuxDevice())
            .withBrowser(ChromeBrowser(version: "135.0.0.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
        XCTAssertEqual(ua, expected)
    }
    
    func testChromeOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(ChromeBrowser(version: "123.0.6312.86"))
            .generate()
        
        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Safari/537.36"
        XCTAssertEqual(ua, expected)
    }
    
    func testFirefoxOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice())
            .withBrowser(FirefoxBrowser(version: "137.1"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/137.1 Mobile/15E148 Safari/604.1"
        XCTAssertEqual(ua, expected)
    }
    
    func testSafariOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(SafariBrowser())
            .generate()
        
        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 16_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.1 Safari/605.1.15"
        XCTAssertEqual(ua, expected)
    }
    
    func testFirefoxOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(FirefoxBrowser(version: "137.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 16.0; rv:137.0) Gecko/20100101 Firefox/137.0"
        XCTAssertEqual(ua, expected)
    }
    
    func testOperaOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice())
            .withBrowser(OperaBrowser(version: "5.5.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1 OPT/5.5.0"
        XCTAssertEqual(ua, expected)
    }
}
