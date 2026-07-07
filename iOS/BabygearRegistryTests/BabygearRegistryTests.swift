import XCTest
@testable import BabygearRegistry

@MainActor
final class BabygearRegistryTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.save()
    }

    func testAddItem() {
        let item = GearItem(itemName: "Test", size: "Note")
        store.add(item)
        XCTAssertEqual(store.items.count, 1)
    }

    func testAddInsertsAtFront() {
        store.add(GearItem(itemName: "First", size: ""))
        store.add(GearItem(itemName: "Second", size: ""))
        XCTAssertEqual(store.items.first?.itemName, "Second")
    }

    func testDeleteItem() {
        let item = GearItem(itemName: "ToDelete", size: "")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testDeleteAtOffsets() {
        store.add(GearItem(itemName: "A", size: ""))
        store.add(GearItem(itemName: "B", size: ""))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitAllowsAdding() {
        for i in 0..<Store.freeLimit {
            store.add(GearItem(itemName: "Item \(i)", size: ""))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        XCTAssertFalse(store.canAddMore)
    }

    func testCanAddMoreWhenUnderLimit() {
        store.add(GearItem(itemName: "One", size: ""))
        XCTAssertTrue(store.canAddMore)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(GearItem(itemName: "Item \(i)", size: ""))
        }
        XCTAssertTrue(store.canAddMore)
    }

    func testUpdateItem() {
        var item = GearItem(itemName: "Original", size: "")
        store.add(item)
        item.itemName = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.itemName, "Updated")
    }
}
