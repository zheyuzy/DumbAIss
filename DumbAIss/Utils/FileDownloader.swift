import Foundation
import SwiftUI

class FileDownloader: ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var isDownloading: Bool = false
    @Published var currentDownload: String = ""
    
    static let shared = FileDownloader()
    
    private init() {}
    
    func downloadFile(from urlString: String, fileName: String, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        DispatchQueue.main.async {
            self.isDownloading = true
            self.currentDownload = fileName
            self.downloadProgress = 0
        }
        
        let task = URLSession.shared.downloadTask(with: url) { [weak self] tempURL, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadProgress = 0
                }
                completion(.failure(error))
                return
            }
            
            guard let tempURL = tempURL else {
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadProgress = 0
                }
                completion(.failure(NSError(domain: "No file URL", code: 0)))
                return
            }
            
            let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
            let destinationURL = downloadsDirectory.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadProgress = 1.0
                    self?.currentDownload = ""
                }
                
                completion(.success(destinationURL))
            } catch {
                DispatchQueue.main.async {
                    self?.isDownloading = false
                    self?.downloadProgress = 0
                }
                completion(.failure(error))
            }
        }
        
        // Add progress observation
        let observation = task.progress.observe(\.fractionCompleted) { [weak self] progress, _ in
            DispatchQueue.main.async {
                self?.downloadProgress = progress.fractionCompleted
            }
        }
        
        task.resume()
    }
    
    func downloadMedia(from url: URL, suggestedFilename: String) {
        // Handle filename conflicts
        var finalFilename = suggestedFilename
        var counter = 1
        let downloadsDirectory = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        
        while FileManager.default.fileExists(atPath: downloadsDirectory.appendingPathComponent(finalFilename).path) {
            let nsFilename = suggestedFilename as NSString
            let filename = nsFilename.deletingPathExtension
            let ext = nsFilename.pathExtension
            finalFilename = "\(filename) (\(counter)).\(ext)"
            counter += 1
        }
        
        downloadFile(from: url.absoluteString, fileName: finalFilename) { result in
            switch result {
            case .success(let fileURL):
                print("Downloaded to: \(fileURL.path)")
                NSWorkspace.shared.activateFileViewerSelecting([fileURL])
            case .failure(let error):
                print("Download failed: \(error)")
            }
        }
    }
} 