import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            // Compact top bar with both selectors and layout toggle
            HStack(spacing: 12) {
                ServiceSelector(
                    selectedService: appState.leftPanelService,
                    onServiceSelected: { appState.setLeftPanelService($0) },
                    label: "Left"
                )
                ServiceSelector(
                    selectedService: appState.rightPanelService,
                    onServiceSelected: { appState.setRightPanelService($0) },
                    label: "Right"
                )
                Spacer()
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
                    if let service = appState.leftService {
                        AIServicePane(service: service)
                            .id(service.id)
                    }
                    if let service = appState.rightService {
                        AIServicePane(service: service)
                            .id(service.id)
                    }
                }
            } else {
                VStack(spacing: 0) {
                    if let service = appState.leftService {
                        AIServicePane(service: service)
                            .id(service.id)
                    }
                    if let service = appState.rightService {
                        AIServicePane(service: service)
                            .id(service.id)
                    }
                }
            }
        }
    }
}

struct ServiceSelector: View {
    let selectedService: String
    let onServiceSelected: (String) -> Void
    let label: String
    
    var body: some View {
        Picker(label, selection: Binding(
            get: { selectedService },
            set: { onServiceSelected($0) }
        )) {
            ForEach(AIService.allServices) { service in
                HStack {
                    Image(systemName: service.icon)
                    Text(service.name)
                }
                .tag(service.id)
            }
        }
        .pickerStyle(.menu)
        .frame(width: 140)
        .help("Select AI for \(label) panel")
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
} 