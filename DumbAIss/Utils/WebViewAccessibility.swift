import Foundation
import WebKit
import AppKit

class WebViewAccessibility {
    // MARK: - Public API

    /// Finds the first focusable text area or text field within the given WKWebView.
    /// Prioritizes already focused elements.
    static func findTextInputElement(in webView: WKWebView, completion: @escaping (NSView?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var focusedElement: NSView?
            var firstInputElement: NSView?

            // Traverse the accessibility children of the webView
            func traverse(_ element: NSView) {
                if focusedElement != nil { return }
                if let role = element.accessibilityRole(), (role == .textField || role == .textArea) {
                    if firstInputElement == nil {
                        firstInputElement = element
                    }
                    // Check if the element is accessibility focused
                    if element.responds(to: Selector(("accessibilityElementIsFocused"))) {
                        if let focused = element.perform(Selector(("accessibilityElementIsFocused")))?.takeUnretainedValue() as? Bool, focused {
                            focusedElement = element
                            return
                        }
                    }
                }
                if let children = element.accessibilityChildren() as? [NSView] {
                    for child in children {
                        traverse(child)
                        if focusedElement != nil { return }
                    }
                }
            }

            DispatchQueue.main.sync {
                traverse(webView)
            }

            DispatchQueue.main.async {
                completion(focusedElement ?? firstInputElement)
            }
        }
    }

    /// Sets the value of a given accessibility element (e.g., a text field).
    static func setValue(of element: NSView, to text: String) -> Bool {
        // Not supported for system views; you may need to use JavaScript for WKWebView
        print("WebViewAccessibility: Setting value is not supported for NSView. Use JavaScript for WKWebView.")
        return false
    }

    /// Attempts to set focus to the given accessibility element.
    static func focus(on element: NSView) -> Bool {
        // Not supported for system views; you may need to use JavaScript for WKWebView
        print("WebViewAccessibility: Focusing is not supported for NSView. Use JavaScript for WKWebView.")
        return false
    }

    /// Simulates pressing the Enter key on an element (not always possible via accessibility API).
    static func simulateEnterKey(for element: NSView) -> Bool {
        // There is no direct way to simulate Enter key via accessibility for NSView.
        print("WebViewAccessibility: Simulating 'Enter' key is not supported via accessibility API.")
        return false
    }
}
