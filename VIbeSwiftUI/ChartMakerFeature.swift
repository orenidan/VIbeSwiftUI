import ComposableArchitecture
import SwiftUI // For UUID, Color, etc. - though Color might move to View-specific state if needed
import Charts // For DisplayChartType if we move it here, or it stays in view

// Forward declaration for ChartDataPoint if it remains in its own file
// (Assuming ChartDataPoint.swift, FocusableField.swift, DisplayChartType are accessible)

@Reducer
internal struct ChartMakerFeature {
    @ObservableState
    internal struct State: Equatable {
        // Define a simple identifiable struct for navigation destination
        struct FullScreenChartPresentationState: Equatable, Identifiable {
            let id = UUID() // Conformance to Identifiable
            // Add any specific data needed by FullScreenChartView if necessary
        }

        var dataPoints: IdentifiedArrayOf<DataPointRowFeature.State> = []
        var showChart: Bool = false // To control overall chart section visibility
        var focusedField: FocusableField? = nil

        // Properties for ActualChartView's internal state, now managed here
        var currentChartType: DisplayChartType = .bar
        var isChartMinimized: Bool = false
        var fullScreenChart: FullScreenChartPresentationState? = nil // New state for navigation destination
        var showClearAllConfirmation: Bool = false // New state for confirmation dialog

        // Computed property to determine if chart section should be shown
        var shouldShowChartSection: Bool {
            // Explicitly use contains(where:) for clarity and correctness
            dataPoints.contains(where: { dataPointRowState in
                let point = dataPointRowState.chartDataPoint
                return point.value != nil && !point.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            })
        }

        // Computed property to check if there are any data points to clear
        var canClearAll: Bool {
            !dataPoints.isEmpty
        }

        // Initializer for sample data or default state
        init() {
            self.dataPoints = [
                DataPointRowFeature.State(chartDataPoint: ChartDataPoint(title: "Apples 🍎", valueString: "50")),
                DataPointRowFeature.State(chartDataPoint: ChartDataPoint(title: "Bananas 🍌", valueString: "80")),
                DataPointRowFeature.State(chartDataPoint: ChartDataPoint(title: "Cherries 🍒", valueString: "30"))
            ]
            self.showChart = shouldShowChartSection // Initialize based on data
        }
    }

    internal enum Action: Equatable {
        case addDataPointButtonTapped
        case dataPoint(IdentifiedActionOf<DataPointRowFeature>) // Actions for individual rows
        case deleteDataPoints(IndexSet)
        case clearAllDataPoints
        case showClearAllConfirmation(Bool)

        case setShowChart(Bool) // To explicitly set showChart, driven by data presence
        case focusFieldChanged(FocusableField?)

        // Actions for ActualChartView
        case chartTypeSelected(DisplayChartType)
        case chartMinimizeButtonTapped
        case onAppear // To calculate initial showChart state
        case setFullScreenChart(isPresented: Bool) // New action to control presentation
    }

    // Dependency for UUID generation
    @Dependency(\.uuid) var uuid

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.showChart = state.shouldShowChartSection
                return .none

            case .addDataPointButtonTapped:
                let newChartPoint = ChartDataPoint(id: self.uuid())
                // Wrap the new ChartDataPoint in DataPointRowFeature.State before appending
                let newDataPointRowState = DataPointRowFeature.State(chartDataPoint: newChartPoint)
                state.dataPoints.append(newDataPointRowState)
                return .none

            case .dataPoint(.element(_, .binding(_))):
                // When a binding changes in a row, DataPointRowFeature.State's chartDataPoint is updated.
                // Then, re-evaluate shouldShowChartSection.
                state.showChart = state.shouldShowChartSection
                return .none

            case .dataPoint: // Catch-all for other dataPoint actions if any in future
                return .none

            case let .deleteDataPoints(indexSet):
                state.dataPoints.remove(atOffsets: indexSet)
                state.showChart = state.shouldShowChartSection
                return .none

            case let .setShowChart(shouldShow):
                state.showChart = shouldShow
                return .none

            case let .focusFieldChanged(newFocusField):
                state.focusedField = newFocusField
                return .none

            // ChartView actions
            case let .chartTypeSelected(type):
                state.currentChartType = type
                return .none

            case .chartMinimizeButtonTapped:
                state.isChartMinimized.toggle()
                return .none

            case let .setFullScreenChart(isPresented):
                if isPresented {
                    state.fullScreenChart = State.FullScreenChartPresentationState()
                } else {
                    state.fullScreenChart = nil
                }
                return .none

            case .clearAllDataPoints:
                state.dataPoints.removeAll()
                state.showChart = false
                return .none

            case let .showClearAllConfirmation(shouldShow):
                state.showClearAllConfirmation = shouldShow
                return .none
            }
        }
        .forEach(\.dataPoints, action: \.dataPoint) {
            DataPointRowFeature()
        }
    }
}

// Reducer for individual data point rows
@Reducer
internal struct DataPointRowFeature {

    @ObservableState
    internal struct State: Equatable, Identifiable {
        var id: ChartDataPoint.ID // This ID must match the ID of the chartDataPoint
        var chartDataPoint: ChartDataPoint

        // Initializer to bridge from ChartDataPoint to DataPointRowFeature.State
        init(chartDataPoint: ChartDataPoint) {
            self.id = chartDataPoint.id // Ensure the row's ID is derived from the data point's ID
            self.chartDataPoint = chartDataPoint
        }
    }

    internal enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            // Use EmojiUtility to add fruit emojis to the title
            let originalTitle = state.chartDataPoint.title
            let enhancedTitle = EmojiUtility.addFruitEmojis(to: originalTitle)

            // Only update the state if the title actually changed
            // to prevent potential infinite loops if the binding itself triggers further processing
            if state.chartDataPoint.title != enhancedTitle {
                state.chartDataPoint.title = enhancedTitle
            }

            return .none
        }
    }
}

// Ensure ChartDataPoint is adaptable or directly usable by DataPointRowFeature.State
// If ChartDataPoint remains a simple struct, DataPointRowFeature.State can hold it directly
// and use @Binding for its fields in the view, or we make ChartDataPoint itself @ObservableState
// For now, the @Presents approach for ChartDataPoint in DataPointRowFeature.State is a common pattern for list elements.
// We need to make sure ChartDataPoint is Equatable.

// DisplayChartType and FocusableField are assumed to be defined elsewhere and Equatable.
// If not, they need to be conformed.
