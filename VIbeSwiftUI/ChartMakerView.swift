import SwiftUI
import ComposableArchitecture
import Charts

internal struct ChartMakerView: View {
    @Bindable var store: StoreOf<ChartMakerFeature>
    @FocusState private var focusedField: FocusableField?

    private var dataList: some View {
        List {
            ForEach(store.scope(state: \.dataPoints, action: \.dataPoint)) { rowStore in
                ChartDataInputRowView(store: rowStore, focusState: $focusedField)
            }
            .onDelete { indexSet in
                store.send(.deleteDataPoints(indexSet))
            }

            Button(action: { store.send(.addDataPointButtonTapped) }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Add Data Row")
                }
            }
            .buttonStyle(.plain)

            if store.canClearAll {
                Button(action: { store.send(.showClearAllConfirmation(true)) }) {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .foregroundColor(.red)
                        Text("Clear All")
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    store.send(.focusFieldChanged(nil))
                }
            }
        }
    }

    internal var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                VStack(spacing: 0) {
                    dataList

                    if store.showChart {
                        ActualChartView(store: self.store)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.Background.primary.ignoresSafeArea(.container, edges: .bottom))
                .animation(AppTheme.Animation.standard, value: store.showChart)
                .navigationTitle("Chart Maker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
                .navigationDestination(item: Binding(
                    get: { store.fullScreenChart },
                    set: { _ in store.send(.setFullScreenChart(isPresented: false)) }
                )) { _ in
                    FullScreenChartView(store: store)
                }
                .confirmationDialog(
                    "Clear All Data",
                    isPresented: Binding(
                        get: { store.showClearAllConfirmation },
                        set: { _ in store.send(.showClearAllConfirmation(false)) }
                    )
                ) {
                    Button("Clear All", role: .destructive) {
                        store.send(.clearAllDataPoints)
                    }
                    Button("Cancel", role: .cancel) {
                        store.send(.showClearAllConfirmation(false))
                    }
                } message: {
                    Text("This will delete all data points. This action cannot be undone.")
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
            if let firstDataPointId = store.dataPoints.first?.id {
                focusedField = .title(firstDataPointId)
            }
        }
        .onChange(of: focusedField) { oldValue, newValue in
            store.send(.focusFieldChanged(newValue))
        }
        .onChange(of: store.focusedField) { oldValue, newValue in
            if focusedField != newValue {
                focusedField = newValue
            }
        }
    }
}

#Preview {
    ChartMakerView(
        store: Store(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }
    )
}
