import XCTest
@testable import APUserAgentGenerator

final class APBrowserUserAgentGeneratorTests: XCTestCase {
    
    func testGenerateDefaultUserAgent() {
        let generator = APBrowserUserAgentGenerator()
        let result = generator.generate()
        
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(osVersion.majorVersion).\(osVersion.minorVersion)"
        let underscoredVersion = versionString.replacingOccurrences(of: ".", with: "_")
        
        let expectedUA = "Mozilla/5.0 (iPhone; CPU iPhone OS \(underscoredVersion) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(versionString) Mobile/15E148 Safari/604.1"
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateSafariOniOSUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .safari, platform: .iOS)
        generator.browserVersion = "18.4"
        generator.osVersion = "18.4"
        
        let expectedUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateChromeOnAndroidUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .chrome, platform: .android)
        generator.browserVersion = "79.0.3945.136"
        generator.osVersion = "10"
        generator.deviceModel = "Pixel 2"
        
        let expectedUA = "Mozilla/5.0 (Linux; Android 10; Pixel 2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/79.0.3945.136 Mobile Safari/537.36"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateChromeOnWindowsUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .chrome, platform: .windows)
        generator.browserVersion = "122.0.6261.129"
        generator.osVersion = "10.0"
        
        let expectedUA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.6261.129 Safari/537.36"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateSafariOnMacOSUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .safari, platform: .macOS)
        generator.browserVersion = "17.4"
        generator.osVersion = "14.4"
        
        let expectedUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateChromeOnMacOSUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .chrome, platform: .macOS)
        generator.browserVersion = "123.0.6312.86"
        generator.osVersion = "14.4"
        
        let expectedUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Safari/537.36"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateFirefoxOnMacOSUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .firefox, platform: .macOS)
        generator.browserVersion = "137.0"
        generator.osVersion = "10.15"
        
        let expectedUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:137.0) Gecko/20100101 Firefox/137.0"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateEdgeOnWindowsUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .edge, platform: .windows)
        generator.browserVersion = "123.0.2420.65"
        generator.osVersion = "10.0"
        
        let expectedUA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.2420.65 Safari/537.36 Edg/123.0.2420.65"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateOperaOnAndroidUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .opera, platform: .android)
        generator.browserVersion = "108.0.0.0"
        generator.osVersion = "13"
        generator.deviceModel = "Pixel 5"
        
        let expectedUA = "Mozilla/5.0 (Linux; Android 13; Pixel 5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Mobile Safari/537.36 OPR/108.0.0.0"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateFirefoxOniOSUserAgent() {
        let generator = APBrowserUserAgentGenerator(browser: .firefox, platform: .iOS)
        generator.browserVersion = "137.1"
        generator.osVersion = "18.4"
        
        let expectedUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/137.1 Mobile/15E148 Safari/605.1.15"
        let result = generator.generate()
        
        XCTAssertEqual(result, expectedUA)
    }
    
    func testGenerateOperaOniOSUserAgent() {
           let generator = APBrowserUserAgentGenerator(browser: .opera, platform: .iOS)
           generator.browserVersion = "5.5.0"
           generator.osVersion = "18.4"

           let expectedUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1 OPT/5.5.0"
           let result = generator.generate()

           XCTAssertEqual(result, expectedUA)
       }
}
