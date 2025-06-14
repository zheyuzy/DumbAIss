import SwiftUI
import WebKit

struct AIServicePane: View {
    let service: AIService
    @State private var isLoading = false
    @StateObject private var downloader = FileDownloader.shared
    
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
                AIWebView(url: service.url, isLoading: $isLoading)
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
    }
} 