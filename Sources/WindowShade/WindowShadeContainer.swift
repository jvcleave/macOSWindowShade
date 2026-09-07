import AppKit
import SwiftUI

/// Hosts SwiftUI content in a window that can collapse to its native title bar.
public struct WindowShadeContainer<Content: View>: View {
    private let controller: WindowShadeController
    private let content: Content

    public init(
        controller: WindowShadeController,
        @ViewBuilder content: () -> Content
    ) {
        self.controller = controller
        self.content = content()
    }

    public var body: some View {
        Group {
            if controller.isShaded {
                Color.clear
                    .frame(height: 0)
            } else {
                content
            }
        }
        .background {
            WindowShadeWindowAccessor(controller: controller)
                .frame(width: 0, height: 0)
        }
    }
}

private struct WindowShadeWindowAccessor: NSViewRepresentable {
    let controller: WindowShadeController

    func makeNSView(context: Context) -> WindowShadeWindowObservationView {
        let observationView = WindowShadeWindowObservationView()
        observationView.windowChanged = { window in
            controller.attachWindow(window)
        }
        return observationView
    }

    func updateNSView(_ nsView: WindowShadeWindowObservationView, context: Context) {
        controller.attachWindow(nsView.window)
    }
}

private final class WindowShadeWindowObservationView: NSView {
    var windowChanged: ((NSWindow?) -> Void)?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        windowChanged?(window)
    }
}
