import AppKit
import Observation

/// Controls the classic macOS window-shade interaction for one window.
///
/// Attach the controller with ``WindowShadeContainer``. The controller listens
/// for double-clicks in the native title bar and can also be driven from custom
/// controls with ``toggleShade()``.
@MainActor
@Observable
public final class WindowShadeController {
    /// Whether the attached window is currently collapsed to its title bar.
    public private(set) var isShaded = false

    /// Whether frame changes use AppKit's standard window animation.
    public var animatesTransitions: Bool

    /// Whether a title-bar double-click toggles the shade.
    public var handlesTitleBarDoubleClick: Bool

    @ObservationIgnored private weak var window: NSWindow?
    @ObservationIgnored private var expandedFrame: NSRect?
    @ObservationIgnored private var expandedContentMinSize = NSSize.zero
    @ObservationIgnored private var expandedMinSize = NSSize.zero
    @ObservationIgnored private var suppressesTitleBarMouseUp = false
    @ObservationIgnored private var wasResizable = true
    @ObservationIgnored nonisolated(unsafe) private var titleBarEventMonitor: Any?

    public init(
        animatesTransitions: Bool = true,
        handlesTitleBarDoubleClick: Bool = true
    ) {
        self.animatesTransitions = animatesTransitions
        self.handlesTitleBarDoubleClick = handlesTitleBarDoubleClick
    }

    deinit {
        if let titleBarEventMonitor {
            NSEvent.removeMonitor(titleBarEventMonitor)
        }
    }

    /// Attaches the controller to an AppKit window.
    ///
    /// SwiftUI clients normally get this automatically from
    /// ``WindowShadeContainer``. The method is public so AppKit clients can use
    /// the same controller directly.
    public func attachWindow(_ window: NSWindow?) {
        if self.window !== window {
            if let titleBarEventMonitor {
                NSEvent.removeMonitor(titleBarEventMonitor)
            }

            self.window = window
            titleBarEventMonitor = nil

            if let window {
                titleBarEventMonitor = NSEvent.addLocalMonitorForEvents(
                    matching: [.leftMouseDown, .leftMouseUp]
                ) { [weak self, weak window] event in
                    if let self, let window, event.window === window {
                        switch event.type {
                        case .leftMouseDown:
                            if self.handlesTitleBarDoubleClick && event.clickCount == 2 {
                                let windowButtons = [
                                    window.standardWindowButton(.closeButton),
                                    window.standardWindowButton(.miniaturizeButton),
                                    window.standardWindowButton(.zoomButton)
                                ]

                                for windowButton in windowButtons {
                                    if let windowButton, let buttonSuperview = windowButton.superview {
                                        let buttonPoint = buttonSuperview.convert(event.locationInWindow, from: nil)
                                        if windowButton.frame.contains(buttonPoint) {
                                            return event
                                        }
                                    }
                                }

                                if event.locationInWindow.y >= window.contentLayoutRect.maxY {
                                    self.suppressesTitleBarMouseUp = true
                                    self.toggleShade()
                                    return nil
                                }
                            }
                        case .leftMouseUp:
                            if self.suppressesTitleBarMouseUp {
                                self.suppressesTitleBarMouseUp = false
                                return nil
                            }
                        default:
                            break
                        }
                    }

                    return event
                }
            }
        }
    }

    /// Toggles the attached window between expanded and shaded states.
    public func toggleShade() {
        setShaded(!isShaded)
    }

    /// Sets the attached window's shade state.
    public func setShaded(_ shaded: Bool) {
        if let window, !window.styleMask.contains(.fullScreen), shaded != isShaded {
            let currentFrame = window.frame

            if shaded {
                let titleBarHeight = currentFrame.height - window.contentLayoutRect.height
                if titleBarHeight > 0 {
                    expandedFrame = currentFrame
                    expandedContentMinSize = window.contentMinSize
                    expandedMinSize = window.minSize
                    wasResizable = window.styleMask.contains(.resizable)

                    let shadedFrame = NSRect(
                        x: currentFrame.minX,
                        y: currentFrame.maxY - titleBarHeight,
                        width: currentFrame.width,
                        height: titleBarHeight
                    )

                    window.minSize = .zero
                    window.contentMinSize = .zero
                    window.styleMask.remove(.resizable)
                    isShaded = true
                    window.setFrame(
                        shadedFrame,
                        display: true,
                        animate: animatesTransitions
                    )
                }
            } else if let expandedFrame {
                var restoredFrame = expandedFrame
                restoredFrame.origin.x = currentFrame.minX
                restoredFrame.origin.y = currentFrame.maxY - restoredFrame.height

                isShaded = false
                window.minSize = expandedMinSize
                window.contentMinSize = expandedContentMinSize
                if wasResizable {
                    window.styleMask.insert(.resizable)
                }
                window.setFrame(
                    restoredFrame,
                    display: true,
                    animate: animatesTransitions
                )
            }
        }
    }
}
