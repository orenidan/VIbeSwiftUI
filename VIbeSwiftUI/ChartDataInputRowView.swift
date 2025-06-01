import SwiftUI

// Reusable View for a single data input row
internal struct ChartDataInputRowView: View {
    @Binding internal var point: ChartDataPoint
    @FocusState.Binding internal var focusedField: FocusableField?

    internal var body: some View {
        HStack {
            TextField("Item Title", text: $point.title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($focusedField, equals: .title(point.id))
            Divider()
            TextField("Value", text: $point.valueString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
                .focused($focusedField, equals: .value(point.id))
        }
    }
}
