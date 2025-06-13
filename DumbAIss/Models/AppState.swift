import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var enabledServices: Set<String> = Set(AIService.defaultServices.map { $0.id })
    @Published var layout: Layout = .horizontal
    
    enum Layout: String, CaseIterable {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
    }
    
    init() {
        // Ensure exactly two services are enabled by default
        if enabledServices.count != 2 {
            enabledServices = Set(AIService.defaultServices.prefix(2).map { $0.id })
        }
    }
    
    var activeServices: [AIService] {
        AIService.allServices.filter { enabledServices.contains($0.id) }
    }
    
    var availableServices: [AIService] {
        AIService.allServices.filter { !enabledServices.contains($0.id) }
    }
    
    func toggleService(_ serviceId: String) {
        if enabledServices.contains(serviceId) {
            // Only allow disabling if there are more than 2 services enabled
            if enabledServices.count > 2 {
                enabledServices.remove(serviceId)
            }
        } else {
            // If we're at 2 services, remove the first one before adding the new one
            if enabledServices.count >= 2 {
                enabledServices.remove(enabledServices.first!)
            }
            enabledServices.insert(serviceId)
        }
    }
    
    func isServiceEnabled(_ serviceId: String) -> Bool {
        enabledServices.contains(serviceId)
    }
    
    func toggleLayout() {
        layout = layout == .horizontal ? .vertical : .horizontal
    }
}
