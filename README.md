# macOSWindowShade

`WindowShade` is a small Swift package that brings the classic “roll up to the
title bar” interaction to modern macOS windows while retaining the native title
bar and traffic-light controls.

Double-click the title bar to shade or restore the window. A shaded window stays
draggable, and restoring it opens the original window beneath its new location.

## Requirements

- macOS 14 or later
- Swift 6.2 or later

## Add the package

In Xcode, choose **File > Add Package Dependencies…** and use this repository's
URL. Add the `WindowShade` product to your macOS app target.

Wrap the content of the window and retain a controller in SwiftUI state:

```swift
import SwiftUI
import WindowShade

struct ContentView: View {
    @State private var shadeController = WindowShadeController()

    var body: some View {
        WindowShadeContainer(controller: shadeController) {
            VStack {
                Text("My window content")

                Button("Shade Window") {
                    shadeController.toggleShade()
                }
            }
            .frame(minWidth: 500, minHeight: 300)
        }
    }
}
```

`WindowShadeContainer` attaches the controller to the containing `NSWindow` and
removes the content's height while shaded. Use `setShaded(_:)` when you need an
explicit state instead of a toggle. AppKit clients can call `attachWindow(_:)`
directly.

## Example app

Open `Package.swift` in Xcode, select the `WindowShadeExample` scheme, and run
it. You can also launch it from Terminal:

```sh
swift run WindowShadeExample
```

The example supports both title-bar double-clicking and a **Shade Window**
button. The package's tests can be run with `swift test`.
