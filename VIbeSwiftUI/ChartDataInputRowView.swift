import SwiftUI
import ComposableArchitecture

// Reusable View for a single data input row, adapted for TCA
internal struct ChartDataInputRowView: View {
    @Bindable var store: StoreOf<DataPointRowFeature>
    var focusState: FocusState<FocusableField?>.Binding // Pass FocusState binding from parent

    // FocusState for TextFields within this row, managed by parent via .focused view modifier
    // The actual @FocusState will live in the parent (ChartMakerView)
    // and will be passed down to .focused modifier.

    internal var body: some View {
        HStack {
            TextField(
                "Item Title",
                text: $store.chartDataPoint.title
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .focused(focusState, equals: .title(store.id)) // Use passed-in focusState

            Divider()

            TextField(
                "Value",
                text: $store.chartDataPoint.valueString
            )
            .textFieldStyle(RoundedBorderTextFieldStyle())
            #if os(iOS)
            .keyboardType(.decimalPad)
            #endif
            .focused(focusState, equals: .value(store.id)) // Use passed-in focusState
        }
        // If you need to react to focus changes specifically within the row,
        // you might need to send actions up, but typically the parent view
        // that owns the @FocusState would manage applying .focused().
    }
}
