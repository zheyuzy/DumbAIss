import SwiftUI
import AppKit

struct NativeTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onCommit: () -> Void // Callback for when Enter is pressed

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.delegate = context.coordinator
        textField.isBordered = true
        textField.backgroundColor = NSColor.textBackgroundColor // Or any other appropriate color
        textField.textColor = NSColor.textColor
        // Make it look somewhat modern
        textField.focusRingType = .none
        textField.bezelStyle = .roundedBezel
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: NativeTextField

        init(_ parent: NativeTextField) {
            self.parent = parent
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.text = textField.stringValue
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            // This is typically where onCommit would be called if editing ends by losing focus.
            // For Enter key, we'll use a different mechanism if needed, or rely on this.
            // parent.onCommit()
        }

        // Handle Enter key press
        func control(_ control: NSControl, textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            if selector == #selector(NSResponder.insertNewline(_:)) {
                // Enter key was pressed
                parent.onCommit()
                return true // Mark as handled
            }
            return false // Default handling for other commands
        }
    }
}
