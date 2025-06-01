import SwiftUI
import ComposableArchitecture
import Charts // Still needed if any Chart-related types are inadvertently used here, though ideally not.

internal struct ChartMakerView: View {
    @Bindable var store: StoreOf<ChartMakerFeature>

    // The @FocusState for TextFields will live here
    @FocusState private var focusedField: FocusableField?

    internal var body: some View {
        // Bind the store's focusedField to the local @FocusState
        // This requires store.focusedField to be bindable, or use .onChange
        // For TCA @ObservableState, direct binding is preferred if setup correctly.
        // Let's use .onChange for now to explicitly sync, and refine if direct binding from store is easy.

        ZStack(alignment: .bottom) { // Original ZStack for layout if needed, or can be simplified
            NavigationView {
                VStack(spacing: 0) {
                    List {
                        ForEach(store.scope(state: \.dataPoints, action: \.dataPoint)) { rowStore in
                            // Pass the local @FocusState binding to the row view
                            ChartDataInputRowView(store: rowStore, focusState: $focusedField)
                            // The .focused modifiers are now inside ChartDataInputRowView
                        }
                        .onDelete { indexSet in
                            store.send(.deleteDataPoints(indexSet))
                        }

                        Button(action: { store.send(.addDataPointButtonTapped) }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Data Row")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .scrollContentBackground(.hidden)
                    #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                    #else
                    .listStyle(PlainListStyle())
                    #endif
                    .toolbar {
                        #if os(iOS)
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                store.send(.focusFieldChanged(nil)) // Clear focus
                            }
                        }
                        #endif
                    }
                    // .onChange(of: dataPoints) was here, now TCA handles state updates internally.
                    // The onAppear will set the initial showChart state.

                    if store.showChart { // Controlled by ChartMakerFeature.State.showChart
                        ActualChartView(store: self.store)
                        // Since ActualChartView now takes Store<ChartMakerFeature.State, ChartMakerFeature.Action>,
                        // we can pass the store directly or scope it if its actions were a subset.
                        // Assuming its actions are part of ChartMakerFeature.Action directly.
                    }

                    // Use a flexible spacer to push content up and fill remaining space
                    Spacer(minLength: 0)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure VStack tries to fill space
                .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .bottom)) // Changed to .systemBackground
                .animation(.easeInOut, value: store.showChart)
                .navigationTitle("Chart Maker")
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #endif
                }
            }
            #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
        .onAppear { store.send(.onAppear) } // Send .onAppear action
        .onChange(of: focusedField) { oldValue, newValue in // Sync local @FocusState with store
            store.send(.focusFieldChanged(newValue))
        }
        .onChange(of: store.focusedField) { oldValue, newValue in // Sync store change to local @FocusState
            if focusedField != newValue {
                focusedField = newValue
            }
        }
    }
}

// Preview for ChartMakerView
#Preview {
    ChartMakerView(
        store: Store(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }
    )
}
