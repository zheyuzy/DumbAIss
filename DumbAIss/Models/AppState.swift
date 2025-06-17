import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var leftPanelService: String = AIService.defaultServices.first?.id ?? ""
    @Published var rightPanelService: String = AIService.defaultServices.last?.id ?? ""
    @Published var layout: Layout = .horizontal
    
    enum Layout: String, CaseIterable {
        case horizontal = "Horizontal"
        case vertical = "Vertical"
    }
    
    init() {
        // Set default services for left and right panels
        if let firstService = AIService.defaultServices.first {
            leftPanelService = firstService.id
        }
        if let lastService = AIService.defaultServices.last {
            rightPanelService = lastService.id
        }
    }
    
    var leftService: AIService? {
        AIService.allServices.first { $0.id == leftPanelService }
    }
    
    var rightService: AIService? {
        AIService.allServices.first { $0.id == rightPanelService }
    }
    
    var availableServices: [AIService] {
        AIService.allServices
    }
    
    func setLeftPanelService(_ serviceId: String) {
        leftPanelService = serviceId
    }
    
    func setRightPanelService(_ serviceId: String) {
        rightPanelService = serviceId
    }
    
    func toggleLayout() {
        layout = layout == .horizontal ? .vertical : .horizontal
    }
}
