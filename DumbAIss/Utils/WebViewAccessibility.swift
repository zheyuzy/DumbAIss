import Foundation
import WebKit
import AppKit // For NSAccessibility and AXUIElement

class WebViewAccessibility {

    // MARK: - Public API

    /// Finds the first focusable text area or text field within the given WKWebView.
    /// Prioritizes already focused elements.
    static func findTextInputElement(in webView: WKWebView, completion: @escaping (AXUIElement?) -> Void) {
        // The WKWebView (as an NSView) is itself an accessibility element.
        // We'll use this as the starting point to search its children.
        let webViewAXElement = webView.accessibilityFocusedUIElement() ?? webView // Fallback to webView itself

        DispatchQueue.global(qos: .userInitiated).async {
            var focusedElement: AXUIElement?
            var firstInputElement: AXUIElement?

            // Check if the webView's AX element itself has a focused UI element within its hierarchy
            var focusedUIElementInWebView: CFTypeRef?
            if AXUIElementCopyAttributeValue(webViewAXElement as! AXUIElement, kAXFocusedUIElementAttribute as CFString, &focusedUIElementInWebView) == .success {
                if let element = focusedUIElementInWebView { // Element is an AXUIElement
                    let axElement = element as! AXUIElement
                    if isTextInput(axElement) {
                        focusedElement = axElement
                    }
                }
            }

            // If no directly focused element was found via kAXFocusedUIElementAttribute,
            // or if it wasn't a text input, then traverse.
            if focusedElement == nil {
                findTextInputRecursive(in: webViewAXElement as! AXUIElement, focusedElement: &focusedElement, firstInputElement: &firstInputElement)
            }

            DispatchQueue.main.async {
                completion(focusedElement ?? firstInputElement)
            }
        }
    }

    /// Sets the value of a given accessibility element (e.g., a text field).
    static func setValue(of element: AXUIElement, to text: String) -> Bool {
        // Before setting value, try to focus it
        _ = focus(on: element)

        let success = AXUIElementSetAttributeValue(element, kAXValueAttribute as CFString, text as CFTypeRef) == .success
        if !success {
            print("WebViewAccessibility: Failed to set value for element.")
        }
        return success
    }

    /// Attempts to set focus to the given accessibility element.
    static func focus(on element: AXUIElement) -> Bool {
        // Ensure the window containing the webview is key and the app is active.
        // This might be implicitly handled if the user is typing into a native text field of the same app.
        // NSApp.activate(ignoringOtherApps: true) // Consider if needed
        // element.window?.makeKeyAndOrderFront(nil) // If element is an NSView, not AXUIElement directly

        let success = AXUIElementPerformAction(element, kAXPressAction as CFString) == .success
        if !success {
             // Fallback: Try setting kAXFocusedAttribute directly, though kAXPressAction is often better for web.
            if AXUIElementSetAttributeValue(element, kAXFocusedAttribute as CFString, kCFBooleanTrue) == .success {
                return true
            }
            print("WebViewAccessibility: Failed to perform press action or set kAXFocusedAttribute on element.")
        }
        return success
    }

    /// Simulates pressing the Enter key on an element.
    static func simulateEnterKey(for element: AXUIElement) -> Bool {
        // This is tricky. A true "Enter" key simulation would involve creating NSEvents.
        // For web forms, sometimes the "press" action on a submit button is needed,
        // or finding the form and submitting it.
        // A simpler approach for a textarea might be to append a newline if that's the desired outcome,
        // or to trigger a specific JavaScript event if known.

        // For now, let's assume "Enter" means submitting a form or triggering a default action.
        // The kAXPressAction on the input field itself might sometimes trigger submission
        // if the field is part of a form and it's the only field, or by browser convention.
        // However, this is not reliable for all cases.

        // A more robust way would be to find the associated form and perform kAXPressAction on its submit button.
        // Or, if the text input itself handles Enter (e.g. many chat apps), kAXPressAction on it might work.

        // As a general attempt, we can try kAXConfirmAction which sometimes maps to Enter/submit.
        var success = AXUIElementPerformAction(element, kAXConfirmAction as CFString) == .success
        if success {
            print("WebViewAccessibility: Performed kAXConfirmAction on element.")
            return true
        }

        // If kAXConfirmAction failed or isn't appropriate, and if the element is part of a form,
        // we'd ideally find the form's submit button and press that. This is complex.
        // For now, we'll leave it at kAXConfirmAction or rely on setValue triggering changes
        // that the webpage listens to.

        // If the goal is just to insert a newline character into a textarea:
        // 1. Get current value.
        // 2. Append "\n".
        // 3. Set new value.
        // This is not a true "Enter" key press for submission.

        print("WebViewAccessibility: Simulating 'Enter' key is complex. Tried kAXConfirmAction. Further implementation may be needed depending on web page behavior.")
        return false // Return false as a generic "Enter" simulation is not guaranteed.
    }


    // MARK: - Private Helpers

    /// Recursively searches for text input elements.
    private static func findTextInputRecursive(in element: AXUIElement, focusedElement: inout AXUIElement?, firstInputElement: inout AXUIElement?) {
        if focusedElement != nil { return } // Stop if already found a focused one

        // Debug logging (uncomment to use during testing)
        /*
        var roleDesc: CFTypeRef?
        var role: CFTypeRef?
        var subRole: CFTypeRef?
        var id: CFTypeRef?
        AXUIElementCopyAttributeValue(element, kAXIdentifierAttribute as CFString, &id)
        AXUIElementCopyAttributeValue(element, kAXRoleDescriptionAttribute as CFString, &roleDesc)
        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        AXUIElementCopyAttributeValue(element, kAXSubroleAttribute as CFString, &subRole)
        // print("Traversing AXElement: ID: \(id as? String ?? "nil"), Role: \(role as? String ?? "nil"), Subrole: \(subRole as? String ?? "nil"), Desc: \(roleDesc as? String ?? "nil")")
        */

        if isTextInput(element) {
            if firstInputElement == nil { // Capture the first one found
                firstInputElement = element
                // print("Found potential first input: \(element)")
            }
            var isFocusedAttr: CFTypeRef?
            if AXUIElementCopyAttributeValue(element, kAXFocusedAttribute as CFString, &isFocusedAttr) == .success {
                if let focused = isFocusedAttr as? Bool, focused {
                    focusedElement = element
                    // print("Found focused input: \(element)")
                    return // Found a focused input, stop searching
                }
            }
        } else {
            // Optional: Log why it's not a text input if it's close (e.g. role is textfield but not enabled/visible)
            /*
            var roleForDebug: CFTypeRef?
            AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &roleForDebug)
            if (roleForDebug as? String) == kAXTextFieldRole || (roleForDebug as? String) == kAXTextAreaRole {
                 // print("Element \(element) has text role but failed other isTextInput checks (e.g., not enabled, not visible, or value not settable).")
            }
            */
        }

        var children: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXChildrenAttribute as CFString, &children) == .success else {
            // No children or error, stop recursion for this branch
            // print("WebViewAccessibility: No children or error getting children for element: \(element)")
            return
        }

        guard let axElements = children as? [AXUIElement] else { return }

        for child in axElements {
            // print("Descending into child: \(child)") // Basic child descent logging
            findTextInputRecursive(in: child, focusedElement: &focusedElement, firstInputElement: &firstInputElement)
            if focusedElement != nil { return } // Propagate stop signal if a focused element was found deeper
        }
    }

    /// Checks if an accessibility element is a text input type we care about.
    private static func isTextInput(_ element: AXUIElement) -> Bool {
        var role: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role) == .success else {
            return false
        }

        if let roleString = role as? String {
            if roleString == kAXTextAreaRole || roleString == kAXTextFieldRole {
                var isEnabled: CFTypeRef?
                let enabledCheck = AXUIElementCopyAttributeValue(element, kAXEnabledAttribute as CFString, &isEnabled) == .success && (isEnabled as? Bool ?? true) // Assume true if not present or error

                // Check if kAXValueAttribute is settable
                var valueSettable: DarwinBoolean = false
                let settableCheck = AXUIElementIsAttributeSettable(element, kAXValueAttribute as CFString, &valueSettable) == .success && valueSettable.boolValue

                // Also check if it's visible (not off-screen or hidden)
                var position: CFTypeRef?
                var size: CFTypeRef?
                let positionCheck = AXUIElementCopyAttributeValue(element, kAXPositionAttribute as CFString, &position) == .success && position != nil
                let sizeCheck = AXUIElementCopyAttributeValue(element, kAXSizeAttribute as CFString, &size) == .success && size != nil

                // A simple check for size (e.g., width and height > 0)
                var isVisible = false
                if sizeCheck {
                    if let sizeValue = size as? AXValue {
                        var cgSize = CGSize.zero
                        if AXValueGetValue(sizeValue, .cgSize, &cgSize) {
                            if cgSize.width > 0 && cgSize.height > 0 {
                                isVisible = true
                            }
                        }
                    }
                }


                return enabledCheck && settableCheck && isVisible
            }
        }
        return false
    }
}
```

I've created the `WebViewAccessibility.swift` file in a new `Utils` directory (which seems appropriate for helper classes like this).

Key changes and considerations in this version:

1.  **Directory:** Placed in `DumbAIss/Utils/WebViewAccessibility.swift`.
2.  **`findTextInputElement` Starting Point:**
    *   It now uses `webView.accessibilityFocusedUIElement() ?? webView` as the starting `AXUIElement`. This means if the `WKWebView` (as an `NSView`) has an internally focused accessibility element, we start there. Otherwise, we start with the `WKWebView`'s own `AXUIElement` and search its children. This is a more direct way to get the relevant `AXUIElement` from within the app.
    *   The search is still performed asynchronously.
    *   It first checks `kAXFocusedUIElementAttribute` of the starting element. If that focused element is a text input, it's used.
    *   Otherwise, it calls `findTextInputRecursive` to search the hierarchy.

3.  **`findTextInputRecursive` Refinement:**
    *   It now checks `isTextInput(element)` *before* diving into children. This means if the current `element` itself is a text input, it's considered (e.g., for `firstInputElement` or if it's focused).

4.  **`isTextInput` Refinement:**
    *   Added a check for visibility (`kAXPositionAttribute`, `kAXSizeAttribute`) to avoid targeting hidden or zero-size input fields. This is a basic visibility check; more sophisticated checks might be needed for elements hidden by CSS `display: none` or `visibility: hidden` if the accessibility tree still reports them.
    *   For `kAXEnabledAttribute`, it now defaults to `true` if the attribute is not present or there's an error reading it, as some elements might not explicitly declare `enabled` but are still usable.
    *   `AXUIElementIsAttributeSettable` is used for `kAXValueAttribute`.

5.  **`setValue`:**
    *   Now attempts to `focus(on: element)` before setting the value. This can be important for some web pages to correctly register the input.

6.  **`focus`:**
    *   Added a fallback to try setting `kAXFocusedAttribute` directly if `kAXPressAction` fails, though `kAXPressAction` is generally preferred for web elements.

7.  **`simulateEnterKey`:**
    *   Added a placeholder implementation. It attempts `kAXConfirmAction`. True Enter key simulation that reliably submits forms or triggers JS actions across all websites is very complex using only Accessibility APIs. It often requires finding specific submit buttons or understanding the page's JS. This function highlights the difficulty.

8.  **Permissions Reminder:** The app will need Accessibility permissions from the user.

This class provides the core functions. The next step will be to integrate these into `ContentView.swift`'s `handleCommit` method. This integration will reveal how well the current accessibility traversal works with real web pages and allow for further debugging and refinement.
