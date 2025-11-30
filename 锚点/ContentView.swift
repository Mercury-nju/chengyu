import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @AppStorage("hasSeenSerenityGuide") private var hasSeenGuide: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            RehabView()
                .tabItem {
                    Label(L10n.tabCalm, systemImage: "circle.grid.cross")
                }
                .tag(0)
            
            CalmView()
                .tabItem {
                    Label(L10n.isUSVersion ? "Meditate" : "冥想", systemImage: "drop.fill")
                }
                .tag(1)
            
            FlowView()
                .tabItem {
                    Label(L10n.isUSVersion ? "Flow" : "具象", systemImage: "circle.fill")
                }
                .tag(2)
            
            StatusView()
                .tabItem {
                    Label(L10n.isUSVersion ? "Insight" : "洞察", systemImage: "chart.bar")
                }
                .tag(3)
        }
        .accentColor(Theme.text)
        .preferredColorScheme(.dark)
        .environmentObject(ThemeManager.shared)
        .onChange(of: selectedTab) { newValue in
            // Block tab switching if guide is not completed
            if !hasSeenGuide && newValue != 0 {
                selectedTab = 0 // Force back to first tab
            }
            
            // Clear preview mode when leaving home tab
            if newValue != 0 {
                ThemeManager.shared.clearPreview()
            }
        }
    }
}
