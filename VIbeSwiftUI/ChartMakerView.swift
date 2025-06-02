import SwiftUI
import ComposableArchitecture
import Charts

internal struct ChartMakerView: View {
    @Bindable var store: StoreOf<ChartMakerFeature>
    @FocusState private var focusedField: FocusableField?

    internal var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                VStack(spacing: 0) {
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
                                store.send(.focusFieldChanged(nil))
                            }
                        }
                        #endif
                    }

                    if store.showChart {
                        ActualChartView(store: self.store)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .bottom))
                .animation(.easeInOut, value: store.showChart)
                .navigationTitle("Chart Maker")
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #endif
                }
                .navigationDestination(item: Binding(
                    get: { store.fullScreenChart },
                    set: { newState, _ in store.send(.setFullScreenChart(isPresented: newState != nil)) }
                )) { _ in
                    FullScreenChartView(store: self.store)
                }
            }
        }
        .onAppear { store.send(.onAppear) }
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
