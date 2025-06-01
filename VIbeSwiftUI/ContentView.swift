//
//  ContentView.swift
//  VIbeSwiftUI
//
//  Created by Oren Idan on 01/06/2025.
//

import SwiftUI
import Charts // Import for SwiftUI Charts

// ChartDataPoint, FocusableField, ChartDataInputRowView, DisplayChartType, and ActualChartView are now in separate files.

struct ContentView: View {
    @State private var dataPoints: [ChartDataPoint] = [
        ChartDataPoint(title: "Apples", valueString: "50"),
        ChartDataPoint(title: "Bananas", valueString: "80"),
        ChartDataPoint(title: "Cherries", valueString: "30")
    ]
    @State private var showChart = false
    @FocusState private var focusedField: FocusableField?

    private var hasValidDataForChart: Bool {
        dataPoints.contains { $0.value != nil && !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationView {
                VStack(spacing: 0) {
                    List {
                        ForEach($dataPoints) { $point in
                            ChartDataInputRowView(point: $point, focusedField: $focusedField)
                        }
                        .onDelete(perform: deleteItems)

                        Button(action: addRow) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Data Row")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                    #else
                    .listStyle(PlainListStyle()) // Or remove for default macOS style
                    #endif
                    .toolbar {
                        #if os(iOS)
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                focusedField = nil
                            }
                        }
                        #endif
                    }
                    .onChange(of: dataPoints, initial: true) { oldData, newData in
                        withAnimation(.easeInOut) {
                            showChart = hasValidDataForChart
                        }
                    }

                    if showChart {
                        ActualChartView(dataPoints: dataPoints)
                    }

                    if !showChart {
                        Spacer().layoutPriority(-1)
                    }
                }
                .animation(.easeInOut, value: showChart)
                .navigationTitle("Chart Maker")
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #else
                    // No specific EditButton for macOS in this context
                    // macOS list editing is often via onDelete directly or context menus
                    #endif
                }
            }
            #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
            #else
            // No specific style for macOS, allow default behavior
            #endif
        }
    }

    func addRow() {
        withAnimation {
            let newPoint = ChartDataPoint()
            dataPoints.append(newPoint)
        }
    }

    func deleteItems(at offsets: IndexSet) {
        withAnimation {
            dataPoints.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    ContentView()
}
