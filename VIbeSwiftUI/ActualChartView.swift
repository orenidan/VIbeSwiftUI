import SwiftUI
import Charts

// Enum for chart types
internal enum DisplayChartType: String, CaseIterable, Identifiable {
    case bar = "Bar"
    case line = "Line"
    case pie = "Pie"
    internal var id: String { self.rawValue }
}

// Reusable View for displaying the chart
internal struct ActualChartView: View {
    internal let dataPoints: [ChartDataPoint]
    @State private var currentChartType: DisplayChartType = .bar
    @State private var isMinimized: Bool = false // State for minimizing/expanding chart content

    internal var body: some View {
        VStack(spacing: 0) { // Use spacing 0 if elements are too far apart
            HStack {
                Text("Chart Preview")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.easeInOut) {
                        isMinimized.toggle()
                    }
                } label: {
                    Image(systemName: isMinimized ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top) // Padding for the header row
            .padding(.bottom, isMinimized ? 0 : 10) // Less bottom padding if minimized

            if !isMinimized {
                Picker("Chart Type", selection: $currentChartType) {
                    ForEach(DisplayChartType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 5)
                .onChange(of: currentChartType) { oldValue, newValue in
                    print("DEBUG: currentChartType changed from \(oldValue.rawValue) to \(newValue.rawValue)")
                }

                let chartableData = dataPoints.filter { $0.value != nil && ($0.value ?? 0) > 0 && !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

                if chartableData.isEmpty {
                    Text("No valid data (with positive values) to display in chart. Add titles and positive numeric values.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(height: 250) // Maintain similar height for placeholder
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
                                .foregroundStyle(Color.blue) // Simplified
                                .symbol(by: .value("Category", point.title))

                                PointMark(
                                    x: .value("Category", point.title),
                                    y: .value("Value", point.value!)
                                )
                                .foregroundStyle(by: .value("Category", point.title))
                                // .annotation(position: .overlay, alignment: .bottom, spacing: 5) {
                                   // Optional: Text("\(point.value!, specifier: "%.0f")")
                                // }

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
                    .padding(.horizontal) // Keep horizontal padding for chart
                    .padding(.bottom)     // Add bottom padding for chart area
                    // .animation(.easeInOut, value: currentChartType) // Animation for chart type change can be re-enabled if desired
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground)) // Give it a slight background to define its area
        .cornerRadius(10)
        .padding(.horizontal) // Overall padding for the ActualChartView component
        .padding(.bottom, 5) // Padding at the bottom of the component
        .transition(.move(edge: .bottom).combined(with: .opacity)) // Transition for when ContentView shows/hides it
    }
}
