import SwiftUI
import WindowShade

struct ContentView: View {
    @State private var shadeController = WindowShadeController()

    var body: some View {
        WindowShadeContainer(controller: shadeController) {
            ZStack {
                Color(nsColor: .windowBackgroundColor)

                VStack(spacing: 22) {
                    Image(systemName: "macwindow")
                        .font(.system(size: 52, weight: .light))
                        .foregroundStyle(.secondary)

                    VStack(spacing: 8) {
                        Text("WINDOW SHADE")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))

                        Text("Double-click the native title bar to roll this window up, then double-click it again to restore it.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)

                        Text("Drag the collapsed title bar before restoring to see the window reopen beneath its new position.")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 360)
                    }

                    Button("Shade Window") {
                        shadeController.toggleShade()
                    }
                    .keyboardShortcut("s", modifiers: [.command, .shift])
                }
                .padding(32)
            }
        }
    }
}
