import Foundation

public class BillsStore {
    public private(set) var bills: [Bill] = []
    private let fileURL: URL
    
    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("bills.json")
    }
    
    public func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            bills = try JSONDecoder().decode([Bill].self, from: data)
        } catch {
            bills = []
        }
    }
    
    public func save() throws {
        let data = try JSONEncoder().encode(bills)
        try data.write(to: fileURL)
    }
    
    public func add(_ bill: Bill) {
        bills.append(bill)
        try? save()
    }
    
    public func delete(id: UUID) {
        bills.removeAll { $0.id == id }
        try? save()
    }
    
    // Simple analytics helper
    public func monthlyTotalSpend() -> Decimal {
        bills.reduce(0) { $0 + $1.amountDue }
    }
}
