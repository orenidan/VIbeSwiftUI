import Foundation

// Data Model
internal struct ChartDataPoint: Identifiable, Equatable {
    internal let id: UUID
    internal var title: String
    internal var valueString: String

    internal var value: Double? {
        Double(valueString)
    }

    init(id: UUID = UUID(), title: String = "", valueString: String = "") {
        self.id = id
        self.title = title
        self.valueString = valueString
    }
}
