import XCTest
@testable import APUserAgentGenerator

final class APUserAgentGeneratorTests: XCTestCase {
    func testGenerateUserAgentWithAllFields() {
        let generator = APUserAgentGenerator()
        generator.appName = "Analytics"
        generator.appVersion = "25.0"
        generator.platform = "iOS"
        generator.platformArchitecture = "arm64"
        generator.platformVersion = "18.4"
        generator.addPart("304")

        let result = generator.generate()
        XCTAssertEqual(result, "Analytics 25.0 (iOS; arm64; 18.4; 304)")
    }
    
    func testGenerateUserAgentWithoutOverridingDefaults() {
        let generator = APUserAgentGenerator()
        let result = generator.generate()

        XCTAssertFalse(result.isEmpty)
        XCTAssertTrue(result.contains(generator.appName))
        XCTAssertTrue(result.contains("("))
        XCTAssertTrue(result.contains(")"))
    }
    
}
