import AppKit
import Testing
@testable import WindowShade

@Test @MainActor
func shadingCollapsesAndRestoresTheWindow() {
    let window = NSWindow(
        contentRect: NSRect(x: 80, y: 120, width: 500, height: 300),
        styleMask: [.titled, .closable, .miniaturizable, .resizable],
        backing: .buffered,
        defer: false
    )
    let controller = WindowShadeController(animatesTransitions: false)
    controller.attachWindow(window)

    let expandedFrame = window.frame
    let titleBarHeight = expandedFrame.height - window.contentLayoutRect.height
    window.contentMinSize = NSSize(width: 320, height: 180)
    window.minSize = NSSize(width: 340, height: 220)
    let expandedContentMinSize = window.contentMinSize
    let expandedMinSize = window.minSize

    controller.setShaded(true)

    #expect(controller.isShaded)
    #expect(window.frame.height == titleBarHeight)
    #expect(!window.styleMask.contains(.resizable))

    controller.setShaded(false)

    #expect(!controller.isShaded)
    #expect(window.frame == expandedFrame)
    #expect(window.contentMinSize == expandedContentMinSize)
    #expect(window.minSize == expandedMinSize)
    #expect(window.styleMask.contains(.resizable))

    controller.attachWindow(nil)
}

@Test @MainActor
func restoringUsesTheCollapsedWindowsNewTopEdge() {
    let window = NSWindow(
        contentRect: NSRect(x: 40, y: 100, width: 480, height: 280),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered,
        defer: false
    )
    let controller = WindowShadeController(animatesTransitions: false)
    controller.attachWindow(window)

    let expandedHeight = window.frame.height
    controller.setShaded(true)

    var movedFrame = window.frame
    movedFrame.origin = NSPoint(x: 260, y: 620)
    window.setFrame(movedFrame, display: false)
    let movedTopEdge = window.frame.maxY

    controller.setShaded(false)

    #expect(window.frame.minX == movedFrame.minX)
    #expect(window.frame.maxY == movedTopEdge)
    #expect(window.frame.height == expandedHeight)

    controller.attachWindow(nil)
}
