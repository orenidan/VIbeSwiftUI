import SwiftUI
import Charts
import ComposableArchitecture

// Enum for chart types
internal enum DisplayChartType: String, CaseIterable, Identifiable {
    case bar = "Bar"
    case line = "Line"
    case pie = "Pie"
    internal var id: String { self.rawValue }
}

// Chart view component with TCA integration
internal struct ActualChartView: View {
    let store: StoreOf<ChartMakerFeature>
    let showFullScreenButton: Bool

    // Initialize with default parameter
    init(store: StoreOf<ChartMakerFeature>, showFullScreenButton: Bool = true) {
        self.store = store
        self.showFullScreenButton = showFullScreenButton
    }

    internal var body: some View {
        let isMinimized = store.isChartMinimized
        let currentChartType = store.currentChartType

        VStack(spacing: 0) {
            HStack {
                Text("Chart Preview")
                    .font(.headline)
                Spacer()
                // Only show minimize and full-screen buttons when showFullScreenButton is true
                if showFullScreenButton {
                    Button {
                        store.send(.chartMinimizeButtonTapped, animation: .easeInOut)
                    } label: {
                        Image(systemName: isMinimized ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.title2)
                    }
                    Button {
                        store.send(.setFullScreenChart(isPresented: true))
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.title2)
                    }
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

                let chartableData = store.dataPoints.filter { dataPointRowState in
                    let point = dataPointRowState.chartDataPoint
                    return point.value != nil && (point.value ?? 0) > 0 && !point.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }.map(\.chartDataPoint)

                if chartableData.isEmpty {
                    Text("No valid data (with positive values) to display in chart. Add titles and positive numeric values.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(height: 250)
                } else {
                    Chart {
                        ForEach(chartableData) { point in
                            switch currentChartType {
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
                    .frame(height: showFullScreenButton ? 250 : UIScreen.main.bounds.height * 0.6)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(showFullScreenButton ? 10 : 0)
        .padding(.horizontal, showFullScreenButton ? nil : 0)
        .padding(.bottom, showFullScreenButton ? 5 : 0)
    }
}
