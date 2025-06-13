import Foundation
import SwiftUI

struct AIService: Identifiable, Hashable {
    let id: String
    let name: String
    let url: URL
    let icon: String
    let isDefault: Bool
    
    static let allServices: [AIService] = [
        AIService(
            id: "chatgpt",
            name: "ChatGPT",
            url: URL(string: "https://chat.openai.com")!,
            icon: "brain",
            isDefault: true
        ),
        AIService(
            id: "perplexity",
            name: "Perplexity",
            url: URL(string: "https://www.perplexity.ai")!,
            icon: "sparkles",
            isDefault: true
        ),
        AIService(
            id: "claude",
            name: "Claude",
            url: URL(string: "https://claude.ai")!,
            icon: "person.fill",
            isDefault: false
        ),
        AIService(
            id: "gemini",
            name: "Gemini",
            url: URL(string: "https://gemini.google.com")!,
            icon: "wand.and.stars",
            isDefault: false
        ),
        AIService(
            id: "deepseek",
            name: "DeepSeek",
            url: URL(string: "https://chat.deepseek.com")!,
            icon: "magnifyingglass",
            isDefault: false
        )
    ]
    
    static let defaultServices: [AIService] = allServices.filter { $0.isDefault }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AIService, rhs: AIService) -> Bool {
        lhs.id == rhs.id
    }
} 