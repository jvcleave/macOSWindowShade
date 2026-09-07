import SwiftUI

@main
struct WindowShadeExampleApp: App {
    var body: some Scene {
        WindowGroup("Window Shade Example") {
            ContentView()
        }
        .defaultSize(width: 520, height: 360)
    }
}
