import XCTest
@testable import BirdrAPIFoundation

final class BirdrAPIFoundationTests: XCTestCase {
    func testServiceEnvironmentsAreComparable() {
        let dev: ServiceEnvironment = .development
        let qa: ServiceEnvironment = .qualityAssurance
        let stg: ServiceEnvironment = .staging
        let prod: ServiceEnvironment = .production
        let alsoProd: ServiceEnvironment = .production
        XCTAssertLessThan(dev, qa)
        XCTAssertLessThan(qa, stg)
        XCTAssertLessThan(stg, prod)
        XCTAssertEqual(prod, alsoProd)
    }
    
    func testURLBuilder() {
        let testURL = URLBuilder(.http, host: "localhost", port: 8080, path: ["image", "create"])
        XCTAssertEqual(testURL.urlString, "http://localhost:8080/image/create")
        let testURL02 = URLBuilder(.https, host: "localhost", path: ["image", "create"])
        XCTAssertEqual(testURL02.urlString, "https://localhost/image/create")
    }
}
