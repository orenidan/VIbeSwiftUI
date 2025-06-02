import SwiftUI
import ComposableArchitecture

internal struct FullScreenChartView: View {
    let store: StoreOf<ChartMakerFeature>

    internal var body: some View {
        VStack(spacing: 0) {
            ActualChartView(store: store, showFullScreenButton: false)
                .onAppear {
                    // Ensure chart is not minimized when entering full-screen
                    if store.isChartMinimized {
                        store.send(.chartMinimizeButtonTapped)
                    }
                }
        }
        .navigationTitle("Full Screen Chart")
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    store.send(.setFullScreenChart(isPresented: false))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FullScreenChartView(
            store: Store(initialState: ChartMakerFeature.State()) {
                ChartMakerFeature()
            }
        )
    }
}
