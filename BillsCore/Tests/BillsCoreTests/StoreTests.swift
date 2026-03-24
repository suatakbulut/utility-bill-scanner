import XCTest
@testable import BillsCore

final class StoreTests: XCTestCase {
    func testAddAndSave() {
        let store = BillsStore(fileURL: URL(fileURLWithPath: "/tmp/test.json"))
        let bill = Bill(providerName: "Test", billType: .electricity, amountDue: 100)
        store.add(bill)
        XCTAssertEqual(store.bills.count, 1)
    }
}
