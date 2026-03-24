import Foundation

public enum BillType: String, CaseIterable, Codable, Identifiable {
    case electricity = "Electricity"
    case gas = "Gas"
    case water = "Water"
    case internet = "Internet"
    case phone = "Phone"
    case other = "Other"
    
    public var id: String { rawValue }
    public var icon: String {
        switch self {
        case .electricity: "bolt.fill"
        case .gas: "flame.fill"
        case .water: "drop.fill"
        case .internet: "wifi"
        case .phone: "iphone"
        case .other: "doc.text"
        }
    }
}

public struct ParsedBillData: Codable {
    public var providerName: String?
    public var billType: BillType?
    public var amountDue: Decimal?
    public var dueDate: Date?
    public var usageAmount: Decimal?
    public var usageUnit: String?
    public var usagePeriodStart: Date?
    public var usagePeriodEnd: Date?
}

public struct Bill: Identifiable, Codable {
    public let id: UUID
    public var createdAt: Date
    public var providerName: String
    public var billType: BillType
    public var amountDue: Decimal
    public var currencyCode: String = "USD"
    public var dueDate: Date?
    public var usageAmount: Decimal?
    public var usageUnit: String?
    public var usagePeriodStart: Date?
    public var usagePeriodEnd: Date?
    public var notes: String?
    public var imageFilePath: String?
    
    public init(
        id: UUID = UUID(),
        providerName: String,
        billType: BillType,
        amountDue: Decimal,
        dueDate: Date? = nil,
        usageAmount: Decimal? = nil,
        usageUnit: String? = nil,
        usagePeriodStart: Date? = nil,
        usagePeriodEnd: Date? = nil,
        notes: String? = nil,
        imageFilePath: String? = nil
    ) {
        self.id = id
        self.createdAt = Date()
        self.providerName = providerName
        self.billType = billType
        self.amountDue = amountDue
        self.dueDate = dueDate
        self.usageAmount = usageAmount
        self.usageUnit = usageUnit
        self.usagePeriodStart = usagePeriodStart
        self.usagePeriodEnd = usagePeriodEnd
        self.notes = notes
        self.imageFilePath = imageFilePath
    }
}

public enum BillTextParser {
    public static func parse(from text: String) -> ParsedBillData {
        var data = ParsedBillData()
        let lower = text.lowercased()
        
        // Bill type heuristics
        if lower.contains("kwh") || lower.contains("electric") { data.billType = .electricity }
        else if lower.contains("therm") || lower.contains("gas") { data.billType = .gas }
        else if lower.contains("gallon") || lower.contains("water") { data.billType = .water }
        else if lower.contains("gb") || lower.contains("internet") { data.billType = .internet }
        
        // Amount due
        if let range = text.range(of: #"\$?(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#, options: .regularExpression) {
            let match = String(text[range])
            data.amountDue = Decimal(string: match.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: ""))
        }
        
        // Provider (first capitalized line that is not date/address)
        let lines = text.split(separator: "\n")
        for line in lines.prefix(5) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.count > 3 && trimmed.first?.isUppercase == true && !trimmed.contains("@") {
                data.providerName = String(trimmed.prefix(30))
                break
            }
        }
        
        // Simple date heuristics (improve later)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let dueMatch = text.range(of: #"\b\d{1,2}/\d{1,2}/\d{4}\b"#, options: .regularExpression) {
            data.dueDate = dateFormatter.date(from: String(text[dueMatch]))
        }
        
        // Usage e.g. "847 kWh"
        if let usageMatch = text.range(of: #"\b(\d+(?:\.\d+)?)\s*(kWh|gallons|GB|therms)\b"#, options: .regularExpression) {
            let parts = String(text[usageMatch]).components(separatedBy: " ")
            data.usageAmount = Decimal(string: parts[0])
            data.usageUnit = parts.count > 1 ? parts[1] : nil
        }
        
        return data
    }
}
