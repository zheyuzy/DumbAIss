import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Service selector toolbar
            HStack {
                ForEach(AIService.allServices) { service in
                    ServiceToggleButton(
                        service: service,
                        isEnabled: appState.isServiceEnabled(service.id),
                        action: { appState.toggleService(service.id) }
                    )
                }
                
                Spacer()
                
                // Layout toggle button
                Button(action: { appState.toggleLayout() }) {
                    Image(systemName: appState.layout == .horizontal ? "rectangle.split.2x1" : "rectangle.split.1x2")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                .help("Toggle layout")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            // Main content area
            if appState.layout == .horizontal {
                HStack(spacing: 0) {
                    ForEach(appState.activeServices) { service in
                        AIServicePane(service: service)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    ForEach(appState.activeServices) { service in
                        AIServicePane(service: service)
                    }
                }
            }
        }
    }
}

struct ServiceToggleButton: View {
    let service: AIService
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: service.icon)
                Text(service.name)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isEnabled ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .help(isEnabled ? "Disable \(service.name)" : "Enable \(service.name)")
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
} 