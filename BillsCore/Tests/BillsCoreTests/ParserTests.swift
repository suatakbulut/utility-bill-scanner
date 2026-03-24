import XCTest
@testable import BillsCore

final class ParserTests: XCTestCase {
    func testParseElectricityBill() {
        let sample = """
        Duke Energy
        Electricity Bill
        Total due $124.50
        Due 03/15/2026
        Usage 847 kWh
        """
        let parsed = BillTextParser.parse(from: sample)
        XCTAssertEqual(parsed.billType, .electricity)
        XCTAssertEqual(parsed.amountDue, 124.5)
        XCTAssertNotNil(parsed.usageAmount)
    }
    
    func testParseInternetBill() {
        let sample = "Comcast\nInternet\nAmount due $89.99\n250 GB used\nDue date 04/01/2026"
        let parsed = BillTextParser.parse(from: sample)
        XCTAssertEqual(parsed.billType, .internet)
        XCTAssertEqual(parsed.usageUnit, "GB")
    }
}
