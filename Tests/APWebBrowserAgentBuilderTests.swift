import Testing
@testable import APUserAgentGenerator

@Suite("Web Browser User Agent Builder")
struct APWebBrowserAgentBuilderTests {
    
    @Test("Default Configuration")
    func defaultGeneration() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1"
        
        #expect(ua == expected)
    }
    
    @Test("Safari on iOS")
    func safariOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice(osVersion: "18.4"))
            .withBrowser(SafariBrowser(version: "18.4"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.4 Mobile/15E148 Safari/604.1"
        
        #expect(ua == expected)
    }
    
    @Test("Chrome on iOS")
    func chromeOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice(osVersion: "26.0"))
            .withBrowser(ChromeBrowser())
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/148.0.7526.93 Mobile/15E148 Safari/604.1"
        
        #expect(ua == expected)
    }
    
    @Test("Chrome on Android")
    func chromeOnAndroid() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(AndroidDevice(deviceModel: "Pixel 7"))
            .withBrowser(ChromeBrowser(version: "123.0.6312.86"))
            .generate()
        
        let expected = "Mozilla/5.0 (Linux; Android 16; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Mobile Safari/537.36"
        
        #expect(ua == expected)
    }
    
    @Test("Chrome on Linux")
    func chromeOnLinux() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(LinuxDevice())
            .withBrowser(ChromeBrowser(version: "135.0.0.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36"
        
        #expect(ua == expected)
    }
    
    @Test("Chrome on Windows")
    func chromeOnWindows() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(WindowsDevice())
            .withBrowser(ChromeBrowser(version: "123.0.6312.86"))
            .generate()
        
        let expected = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6312.86 Safari/537.36"
        
        #expect(ua == expected)
    }
    
    @Test("Firefox on iOS")
    func firefoxOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice(osVersion: "26.0"))
            .withBrowser(FirefoxBrowser(version: "137.1"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) FxiOS/137.1 Mobile/15E148 Safari/604.1"
        
        #expect(ua == expected)
    }
    
    @Test("Safari on Mac")
    func safariOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(SafariBrowser())
            .generate()
        
        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 16_0) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.1 Safari/605.1.15"
        
        #expect(ua == expected)
    }
    
    @Test("Firefox on Mac")
    func firefoxOnMac() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(MacDevice())
            .withBrowser(FirefoxBrowser(version: "137.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (Macintosh; Intel Mac OS X 16.0; rv:137.0) Gecko/20100101 Firefox/137.0"
        
        #expect(ua == expected)
    }
    
    @Test("Opera on iOS")
    func operaOniOS() {
        let ua = APWebBrowserAgentBuilder
            .builder()
            .withDevice(iOSDevice(osVersion: "26.0"))
            .withBrowser(OperaBrowser(version: "5.5.0"))
            .generate()
        
        let expected = "Mozilla/5.0 (iPhone; CPU iPhone OS 26_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/19.0 Mobile/15E148 Safari/604.1 OPT/5.5.0"
        
        #expect(ua == expected)
    }
}
