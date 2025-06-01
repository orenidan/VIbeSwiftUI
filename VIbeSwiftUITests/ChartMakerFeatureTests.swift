import ComposableArchitecture
import XCTest

@testable import VIbeSwiftUI // Import your app module

@MainActor
final class ChartMakerFeatureTests: XCTestCase {
    func testInitialState() {
        let store = TestStore(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }

        XCTAssertEqual(store.state.dataPoints.count, 3)
        XCTAssertTrue(store.state.showChart) // Based on initial sample data being valid
        XCTAssertEqual(store.state.currentChartType, .bar)
        XCTAssertFalse(store.state.isChartMinimized)
    }

    func testAddDataPoint() async {
        let newUUID = UUID()
        // Start with a state where chart might initially be false if dataPoints is empty
        var initialState = ChartMakerFeature.State()
        initialState.dataPoints = []
        initialState.showChart = initialState.shouldShowChartSection // should be false initially

        let store = TestStore(initialState: initialState) {
            ChartMakerFeature()
        } withDependencies: {
            $0.uuid = .constant(newUUID)
        }

        XCTAssertFalse(store.state.showChart, "Initially, showChart should be false with no data points")
        let initialCount = store.state.dataPoints.count // Should be 0

        await store.send(.addDataPointButtonTapped) {
            // State should update immediately after the action is sent
            $0.dataPoints.append(DataPointRowFeature.State(chartDataPoint: ChartDataPoint(id: newUUID)))
            // showChart is NOT directly changed by .addDataPointButtonTapped in the reducer.
            // It remains false because the new point is empty and shouldShowChartSection is still false.
            // $0.showChart = false // Explicitly assert it doesn't change to true here
        }
        XCTAssertEqual(store.state.dataPoints.count, initialCount + 1)
        XCTAssertEqual(store.state.dataPoints.last?.id, newUUID)
        XCTAssertFalse(store.state.showChart, "showChart should remain false after adding an empty point, as per reducer logic")
    }

    func testDeleteDataPoint() async {
        var initialState = ChartMakerFeature.State()
        // Ensure there's at least one point to delete
        let pointToDeleteID = UUID()
        initialState.dataPoints = [DataPointRowFeature.State(chartDataPoint: ChartDataPoint(id: pointToDeleteID, title: "Test", valueString: "10"))]
        initialState.showChart = initialState.shouldShowChartSection // Should be true

        let store = TestStore(initialState: initialState) {
            ChartMakerFeature()
        }

        XCTAssertTrue(store.state.showChart, "showChart should be true initially with one valid point")
        let countBeforeDelete = store.state.dataPoints.count

        await store.send(.deleteDataPoints(IndexSet(integer: 0))) {
            $0.dataPoints.remove(id: pointToDeleteID)
            $0.showChart = $0.shouldShowChartSection // Recalculate after deletion, should be false
        }

        XCTAssertEqual(store.state.dataPoints.count, countBeforeDelete - 1)
        XCTAssertFalse(store.state.showChart, "showChart should be false after deleting the only valid point")
    }

    func testDeleteAllDataPointsHidesChart() async {
        let store = TestStore(initialState: ChartMakerFeature.State()) { // Starts with 3 sample points
            ChartMakerFeature()
        }

        XCTAssertTrue(store.state.showChart)

        let indicesToDelete = IndexSet(0..<store.state.dataPoints.count)

        await store.send(.deleteDataPoints(indicesToDelete)) {
            $0.dataPoints.removeAll()
            $0.showChart = false // Because shouldShowChartSection will be false
        }
        XCTAssertFalse(store.state.showChart)
        XCTAssertTrue(store.state.dataPoints.isEmpty)
    }

    func testToggleChartMinimization() async {
        let store = TestStore(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }

        XCTAssertFalse(store.state.isChartMinimized)

        await store.send(.chartMinimizeButtonTapped) {
            $0.isChartMinimized = true
        }
        XCTAssertTrue(store.state.isChartMinimized)

        await store.send(.chartMinimizeButtonTapped) {
            $0.isChartMinimized = false
        }
        XCTAssertFalse(store.state.isChartMinimized)
    }

    func testSelectChartType() async {
        let store = TestStore(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }

        XCTAssertEqual(store.state.currentChartType, .bar)

        await store.send(.chartTypeSelected(.line)) {
            $0.currentChartType = .line
        }
        XCTAssertEqual(store.state.currentChartType, .line)

        await store.send(.chartTypeSelected(.pie)) {
            $0.currentChartType = .pie
        }
        XCTAssertEqual(store.state.currentChartType, .pie)
    }

    func testFocusFieldChanged() async {
        let store = TestStore(initialState: ChartMakerFeature.State()) {
            ChartMakerFeature()
        }
        let testUUID = UUID()
        let focusTarget = FocusableField.title(testUUID)

        XCTAssertNil(store.state.focusedField)

        await store.send(.focusFieldChanged(focusTarget)) {
            $0.focusedField = focusTarget
        }
        XCTAssertEqual(store.state.focusedField, focusTarget)

        await store.send(.focusFieldChanged(nil)) {
            $0.focusedField = nil
        }
        XCTAssertNil(store.state.focusedField)
    }

    func testShowChartUpdatesOnDataBinding() async {
        var initialState = ChartMakerFeature.State()
        initialState.dataPoints = []
        initialState.showChart = initialState.shouldShowChartSection // Should be false

        let testID = UUID()
        let store = TestStore(initialState: initialState) {
            ChartMakerFeature()
        } withDependencies: {
            $0.uuid = .constant(testID) // For the new data point's ID
        }

        XCTAssertFalse(store.state.showChart, "Initially, showChart should be false.")

        // 1. Add an empty data point
        await store.send(.addDataPointButtonTapped) {
            $0.dataPoints.append(DataPointRowFeature.State(chartDataPoint: ChartDataPoint(id: testID)))
            // showChart remains false as the new point is empty and shouldShowChartSection is false.
            // $0.showChart = false // No change to showChart by this specific action if it was already false.
        }
        XCTAssertFalse(store.state.showChart, "Chart should remain false after adding an empty point.")
        XCTAssertEqual(store.state.dataPoints.count, 1)
        guard let pointId = store.state.dataPoints.first?.id else {
            XCTFail("Data point should exist after adding.")
            return
        }

        // 2. Simulate a binding action: setting the title of the data point.
        // The reducer's .dataPoint(.element(_, .binding(_))) case should handle this binding
        // and then re-evaluate showChart.
        let newTitle = "Valid Title"
        await store.send(.dataPoint(.element(id: pointId, action: .binding(.set(\DataPointRowFeature.State.chartDataPoint.title, newTitle))))) {
            // The binding action updates the title within the DataPointRowFeature's state.
            $0.dataPoints[id: pointId]?.chartDataPoint.title = newTitle
            // The ChartMakerFeature's reducer then recalculates showChart.
            // Assuming valueString is still empty, showChart should remain false.
            $0.showChart = $0.shouldShowChartSection // This will be false
        }
        XCTAssertFalse(store.state.showChart, "Chart should still be false after only title is set.")
        XCTAssertEqual(store.state.dataPoints[id: pointId]?.chartDataPoint.title, newTitle)

        // 3. Simulate another binding action: setting the valueString of the data point.
        // This should make the data point valid, and showChart should become true.
        let newValueString = "100"
        await store.send(.dataPoint(.element(id: pointId, action: .binding(.set(\DataPointRowFeature.State.chartDataPoint.valueString, newValueString))))) {
            $0.dataPoints[id: pointId]?.chartDataPoint.valueString = newValueString
            // Now that title and valueString are set, shouldShowChartSection should be true.
            $0.showChart = $0.shouldShowChartSection // This will be true
        }
        XCTAssertTrue(store.state.showChart, "Chart should now be true after title and value are set.")
        XCTAssertEqual(store.state.dataPoints[id: pointId]?.chartDataPoint.valueString, newValueString)
    }
}
