import SwiftUI
import WebKit

struct AIServicePane: View {
    @EnvironmentObject var appState: AppState // <--- Add AppState
    let service: AIService
    @State private var isLoading = false
    @StateObject private var downloader = FileDownloader.shared
    
    // Distinguish if this pane is for the 'left' or 'right' service
    // This is a bit simplistic; a better way might be to pass a unique ID or a binding path.
    // For now, we can infer based on the service ID matching AppState's left/right service ID.
    private var isLeftPane: Bool {
        appState.leftService?.id == service.id
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label(service.name, systemImage: service.icon)
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            
            // WebView
            ZStack {
                AIWebView(url: service.url, isLoading: $isLoading, onWebViewCreated: { webView in
                    // Update AppState with the created webView
                    if isLeftPane {
                        //DispatchQueue.main.async { // Ensure UI updates are on main thread
                            appState.leftWebView = webView
                        //}
                    } else {
                        //DispatchQueue.main.async {
                            appState.rightWebView = webView
                        //}
                    }
                })
                .overlay {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                    }
                }
                
                // Download Progress
                if downloader.isDownloading {
                    VStack {
                        Spacer()
                        DownloadProgressView()
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .frame(minWidth: 300, minHeight: 400)
        // When a pane disappears (service changes), nullify the corresponding webview in AppState
        .onDisappear {
            // This is important to prevent stale references if a service is changed.
            // We need to ensure this onDisappear is called correctly when the service ID changes.
            // The .id(service.id) on AIServicePane in ContentView should handle this.
            if isLeftPane && appState.leftWebView?.url == service.url { // Check if it's the same webview
                 //appState.leftWebView = nil
            } else if !isLeftPane && appState.rightWebView?.url == service.url {
                 //appState.rightWebView = nil
            }
        }
    }
} 