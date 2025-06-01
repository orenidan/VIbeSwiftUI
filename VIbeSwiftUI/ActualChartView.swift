import SwiftUI
import Charts
import ComposableArchitecture

// Enum for chart types - already Equatable due to String raw value
internal enum DisplayChartType: String, CaseIterable, Identifiable {
    case bar = "Bar"
    case line = "Line"
    case pie = "Pie"
    internal var id: String { self.rawValue }
}

// Reusable View for displaying the chart, adapted for TCA
internal struct ActualChartView: View {
    // This view will observe a part of the ChartMakerFeature.State
    // It doesn't own the store directly, but observes state passed down.
    // For direct store interaction, it would be `let store: StoreOf<SomeScopedFeature>`
    // or `let store: Store<ChartMakerFeature.State, ChartMakerFeature.Action>`
    // For simplicity here, we'll assume the parent (ChartMakerView) passes necessary state and sends actions.
    // However, a more idiomatic TCA approach for a complex sub-view is often to give it its own ScopedStore.
    // Let's make it take the relevant state directly and provide closures for actions for now,
    // which ChartMakerView will connect to its store.
    // OR, we can make it take a Store<State, Action> that is scoped down.
    // Given its complexity, scoping the store is better.

    let store: StoreOf<ChartMakerFeature> // Scoped store state

    // Define a local State struct that mirrors the part of ChartMakerFeature.State this view cares about.
    // This is useful if we don't want to pass the whole ChartMakerFeature.State or for previewing.
    // For direct use with a scoped store, this can be simpler.
    // Or, define a local subset:
    // struct ViewState: Equatable {
    //     let dataPoints: [ChartDataPoint]
    //     let currentChartType: DisplayChartType
    //     let isMinimized: Bool
    // }
    // let viewState: ViewState
    // let send: (ChartMakerFeature.Action) -> Void // For sending actions back

    internal var body: some View {
        // Access state directly from the store passed in
        let isMinimized = store.isChartMinimized
        let currentChartType = store.currentChartType // No binding needed if picker sends action

        VStack(spacing: 0) {
            HStack {
                Text("Chart Preview")
                    .font(.headline)
                Spacer()
                Button {
                    store.send(.chartMinimizeButtonTapped, animation: .easeInOut)
                } label: {
                    Image(systemName: isMinimized ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom, isMinimized ? 0 : 10)

            if !isMinimized {
                Picker("Chart Type", selection: Binding(
                    get: { store.currentChartType },
                    set: { store.send(.chartTypeSelected($0)) }
                )) {
                    ForEach(DisplayChartType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 5)
                // .onChange is part of TCA reducer logic if state change needs to trigger effects

                let chartableData = store.dataPoints.filter { dataPointRowState in
                    let point = dataPointRowState.chartDataPoint
                    return point.value != nil && (point.value ?? 0) > 0 && !point.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }.map(\.chartDataPoint) // Map to [ChartDataPoint] for the Chart ForEach

                if chartableData.isEmpty {
                    Text("No valid data (with positive values) to display in chart. Add titles and positive numeric values.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(height: 250)
                } else {
                    Chart {
                        ForEach(chartableData) { point in
                            switch currentChartType { // Use the local currentChartType from store state
                            case .bar:
                                BarMark(
                                    x: .value("Category", point.title),
                                    y: .value("Value", point.value!)
                                )
                                .foregroundStyle(by: .value("Category", point.title))
                            case .line:
                                LineMark(
                                    x: .value("Category", point.title),
                                    y: .value("Value", point.value!)
                                )
                                .foregroundStyle(Color.blue)
                                .symbol(by: .value("Category", point.title))

                                PointMark(
                                    x: .value("Category", point.title),
                                    y: .value("Value", point.value!)
                                )
                                .foregroundStyle(by: .value("Category", point.title))

                            case .pie:
                                SectorMark(
                                    angle: .value("Value", point.value!),
                                    innerRadius: .ratio(0.0)
                                )
                                .foregroundStyle(by: .value("Category", point.title))
                                .annotation(position: .overlay) {
                                    Text("\(point.title)\n\(point.value!, specifier: "%.0f")")
                                        .font(.caption)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        if currentChartType != .pie {
                            AxisMarks(preset: .automatic, position: .leading)
                        }
                    }
                    .chartXAxis {
                        if currentChartType != .pie {
                            AxisMarks(preset: .automatic)
                        }
                    }
                    .frame(height: 250)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.bottom, 5)
        // .transition is fine as it's a view property, not state logic
        // However, overall visibility of this view will be controlled by ChartMakerFeature's showChart state
        // which will be handled in ChartMakerView.
    }
}
