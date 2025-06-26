import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var promptText: String = "" // State for the input bar

    var body: some View {
        VStack(spacing: 0) {
            // Compact top bar with both selectors and layout toggle
            HStack(spacing: 12) {
                ServiceSelector(
                    selectedService: appState.leftPanelService,
                    onServiceSelected: { appState.setLeftPanelService($0) },
                    label: appState.layout == .horizontal ? "Left" : "Top"
                )
                Spacer() // Add spacer to push right selector and button
                ServiceSelector(
                    selectedService: appState.rightPanelService,
                    onServiceSelected: { appState.setRightPanelService($0) },
                    label: appState.layout == .horizontal ? "Right" : "Bottom"
                )
                // Spacer() // Removed to keep layout toggle next to right selector
                Button(action: { appState.toggleLayout() }) {
                    Image(systemName: appState.layout == .horizontal ? "rectangle.split.2x1" : "rectangle.split.1x2")
                        .font(.title2) // Consider .title3 or .body for less emphasis if needed
                }
                .buttonStyle(.plain)
                .help("Toggle layout")
            }
            .padding(.horizontal)
            .padding(.vertical, 8) // Adjusted padding
            .background(.ultraThinMaterial)
            
            // Main content area
            if appState.layout == .horizontal {
                HStack(spacing: 0) {
                    if let service = appState.leftService {
                        AIServicePane(service: service)
                            .id("left_" + service.id) // Ensure unique ID when service changes
                    }
                    // Add a divider if both services are present
                    if appState.leftService != nil && appState.rightService != nil {
                        Divider()
                    }
                    if let service = appState.rightService {
                        AIServicePane(service: service)
                            .id("right_" + service.id) // Ensure unique ID
                    }
                }
            } else { // Vertical layout
                VStack(spacing: 0) {
                    if let service = appState.leftService {
                        AIServicePane(service: service)
                            .id("top_" + service.id) // Ensure unique ID
                    }
                    // Add a divider if both services are present
                    if appState.leftService != nil && appState.rightService != nil {
                        Divider()
                    }
                    if let service = appState.rightService {
                        AIServicePane(service: service)
                            .id("bottom_" + service.id) // Ensure unique ID
                    }
                }
            }

            // Native Input Bar
            NativeTextField(
                text: $promptText,
                placeholder: "Type your prompt here for both AIs...",
                onCommit: {
                    handleCommit()
                }
            )
            .padding(.horizontal, 8) // Add some horizontal padding
            .padding(.vertical, 10)  // Add vertical padding
            .frame(height: 44) // Set a fixed height for the input bar area
            .background(.windowBackground) // Use a standard background color
        }
        // Ensure ContentView itself can receive keyboard focus if needed, though NSTextField will handle its own.
        // .focusable()
    }

    private func handleCommit() {
        let textToCommit = promptText
        guard !textToCommit.isEmpty else { return }

        print("Committing prompt: \(textToCommit)")

        let webViewsToTarget = [appState.leftWebView, appState.rightWebView].compactMap { $0 }

        if webViewsToTarget.isEmpty {
            print("No active webviews to send prompt to.")
            self.promptText = "" // Clear if no targets
            return
        }

        let group = DispatchGroup()
        var successfulCommits = 0

        for wv in webViewsToTarget {
            group.enter() // Enter group for each async operation
            WebViewAccessibility.findTextInputElement(in: wv) { element in
                defer { group.leave() } // Leave group when callback finishes

                guard let inputElement = element else {
                    print("Could not find text input element in webview: \(wv.url?.host ?? "unknown")")
                    return
                }

                if WebViewAccessibility.setValue(of: inputElement, to: textToCommit) {
                    print("Successfully set text in webview: \(wv.url?.host ?? "unknown")")
                    successfulCommits += 1

                    // Optional: Attempt to simulate Enter key
                    // if WebViewAccessibility.simulateEnterKey(for: inputElement) {
                    //     print("Successfully simulated Enter in webview: \(wv.url?.host ?? "unknown")")
                    // } else {
                    //     print("Failed to simulate Enter or Enter simulation not applicable for webview: \(wv.url?.host ?? "unknown")")
                    // }
                } else {
                    print("Failed to set text in webview: \(wv.url?.host ?? "unknown")")
                }
            }
        }

        group.notify(queue: .main) { [self] in
            // This block executes after all findTextInputElement callbacks have completed
            print("All accessibility operations attempted. Successful commits: \(successfulCommits)")
            if successfulCommits > 0 || webViewsToTarget.isEmpty {
                // Clear text if at least one commit was successful, or if there were no targets initially
                self.promptText = ""
            } else if successfulCommits == 0 && !webViewsToTarget.isEmpty {
                print("Failed to commit to any webview. Prompt text not cleared.")
                // Optionally, provide feedback to the user that sending failed.
            }
        }
    }
}

struct ServiceSelector: View {
    let selectedService: String
    let onServiceSelected: (String) -> Void
    let label: String
    
    // Access AppState to get the full list of services.
    // Alternatively, pass AIService.allServices directly if preferred.
    @EnvironmentObject var appState: AppState

    var body: some View {
        Picker(label, selection: Binding(
            get: { selectedService },
            set: { onServiceSelected($0) }
        )) {
            ForEach(appState.availableServices) { service in // Use appState.availableServices
                HStack {
                    Image(systemName: service.icon)
                    Text(service.name)
                }
                .tag(service.id)
            }
        }
        .pickerStyle(.menu)
        .frame(minWidth: 150, idealWidth: 180, maxWidth: 200) // Adjust frame for better adaptability
        .help("Select AI for \(label) panel")
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
