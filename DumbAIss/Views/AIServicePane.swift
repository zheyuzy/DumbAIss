import SwiftUI
import WebKit

struct AIServicePane: View {
    let service: AIService
    @State private var isLoading = false
    
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
            AIWebView(url: service.url, isLoading: $isLoading)
                .overlay {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(.ultraThinMaterial)
                    }
                }
        }
        .frame(minWidth: 300, minHeight: 400)
    }
} 