import Foundation

// Data Model
internal struct ChartDataPoint: Identifiable, Equatable {
    internal var id = UUID()
    internal var title: String = ""
    internal var valueString: String = ""

    internal var value: Double? {
        Double(valueString)
    }
}
