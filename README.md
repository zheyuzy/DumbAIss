# DumbAIss - Multi-AI Service Split View

A native macOS application that allows you to compare responses from multiple AI services side by side in a split-view interface.

## Features

- Split-view layout supporting multiple AI services simultaneously
- Support for ChatGPT, Claude, Bard, and Perplexity
- Multiple layout options (2-pane horizontal/vertical, 4-pane grid, 3-pane layout)
- Centralized input system that can send prompts to multiple services
- Resizable and collapsible panes
- Prompt history with keyboard navigation
- Modern SwiftUI interface with native macOS integration

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

## Setup

1. Clone the repository
2. Open `DumbAIss.xcodeproj` in Xcode
3. Build and run the project (⌘R)

## Usage

1. Launch the application
2. Select your desired layout from the toolbar
3. Toggle AI services on/off using the toolbar buttons
4. Enter your prompt in the input bar at the bottom
5. Use the arrow keys to navigate through prompt history
6. Resize panes by dragging the splitter handles

## Layout Options

- **2 Panes Horizontal**: Side-by-side view of two AI services
- **2 Panes Vertical**: Top/bottom view of two AI services
- **4 Panes Grid**: 2x2 grid layout for four AI services
- **3 Panes (1 Large + 2 Small)**: One large pane with two smaller panes

## Notes

- Each AI service runs in its own WebView instance
- The application requires an active internet connection
- You'll need to be logged into each AI service in your browser for full functionality
- Some AI services may require additional authentication or have usage limitations

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 