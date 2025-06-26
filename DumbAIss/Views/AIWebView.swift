import SwiftUI
import WebKit

struct AIWebView: NSViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @StateObject private var downloader = FileDownloader.shared
    
    // Callback to pass the WKWebView instance
    var onWebViewCreated: ((WKWebView) -> Void)? // <--- Add this

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.isTextInteractionEnabled = true
        // Enable developer extras for easier debugging of web content if needed
        // For App Store submission, you might want to wrap this in a #if DEBUG
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Call the callback
        onWebViewCreated?(webView) // <--- Call it here

        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {
        // If the URL changes, we might need to reload or update the webView
        // For now, assuming URL is constant after creation for a given AIWebView instance
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
        var parent: AIWebView
        private var activeDownloads: [WKDownload: URL] = [:]
        
        init(_ parent: AIWebView) {
            self.parent = parent
        }
        
        // MARK: - WKNavigationDelegate
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
        }
        
        // MARK: - WKDownloadDelegate
        func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            // Use FileDownloader instead of direct download
            if let url = response.url {
                FileDownloader.shared.downloadMedia(from: url, suggestedFilename: suggestedFilename)
            }
            completionHandler(nil) // Cancel the WKDownload since we're handling it ourselves
        }
        
        func download(_ download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
        
        func downloadDidFinish(_ download: WKDownload) {
            activeDownloads.removeValue(forKey: download)
        }
        
        func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            print("Download failed: \(error.localizedDescription)")
            activeDownloads.removeValue(forKey: download)
        }
        
        // MARK: - WKUIDelegate
        func webView(_ webView: WKWebView, download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
            self.download(download, decideDestinationUsing: response, suggestedFilename: suggestedFilename, completionHandler: completionHandler)
        }
        
        func webView(_ webView: WKWebView, download: WKDownload, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            self.download(download, didReceive: challenge, completionHandler: completionHandler)
        }
        
        func webView(_ webView: WKWebView, download: WKDownload, didFinishDownloadingTo destinationURL: URL) {
            self.downloadDidFinish(download)
        }
        
        func webView(_ webView: WKWebView, download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
            self.download(download, didFailWithError: error, resumeData: resumeData)
        }
        
        // Handle new window requests
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}

// Download Progress View
struct DownloadProgressView: View {
    @ObservedObject var downloader = FileDownloader.shared
    
    var body: some View {
        if downloader.isDownloading {
            VStack {
                Text("Downloading: \(downloader.currentDownload)")
                    .font(.caption)
                ProgressView(value: downloader.downloadProgress)
                    .progressViewStyle(.linear)
                    .frame(width: 200)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(8)
        }
    }
}
