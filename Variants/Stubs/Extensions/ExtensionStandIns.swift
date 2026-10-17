import SwiftUI

// Stand-ins for Features/Extensions/{Service,UI,Settings}. `Model/` and `ExtensionScreen` stay real:
// they are inert value types the launcher and palette name. Nothing here runs JavaScript.

/// Only the JSON helper `RenderValue` decodes with; there is no JavaScriptCore behind it.
enum ExtensionRuntime {
    static func jsonArray(from json: String) -> [Any] {
        guard let data = json.data(using: .utf8),
            let array = try? JSONSerialization.jsonObject(with: data) as? [Any]
        else { return [] }
        return array
    }
}

enum ExtensionSessionState: Equatable {
    case idle
    case rendered(RenderTree)
}

/// Never starts a runtime and never publishes a command, so no extension row reaches the launcher.
@MainActor
@Observable
final class ExtensionManager {
    private(set) var state: ExtensionSessionState = .idle
    /// `Never?`: there is no command that could be running.
    var running: Never? { nil }
    var isSigningIn: Bool { false }
    var navigationDepth: Int { 1 }
    @ObservationIgnored var onDidUninstall: (([String]) -> Void)?

    init(clipboardStore: ClipboardStore) {}

    func start(appIndex: AppIndex, coordinator: ExtensionCoordinator) {}
    func stop() async {}
    func dispatch(handler: String, arguments: [Any] = []) {}
    func accessorySelection(_ accessory: ExtensionSearchAccessory) -> String? { nil }
    func isBackgroundSchedulable(for entry: AppEntry) -> Bool { false }
    func isBackgroundEnabled(for entry: AppEntry) -> Bool { false }
    func toggleBackgroundRefresh(for entry: AppEntry) {}
    func refreshNow(_ entry: AppEntry) {}
}

@MainActor
final class ExtensionCoordinator {
    private let core: AppCore

    init(
        extensions: ExtensionManager, palette: PaletteState,
        paletteCoordinator: PaletteCoordinator, settingsCoordinator: SettingsCoordinator,
        settings: AppSettings, core: AppCore
    ) {
        self.core = core
    }

    func applyEnabled() {}
    func applyExtensionsLauncherPresence() {}
    /// A shortcut bound by a full build still fires here; say why nothing happens.
    func runExtensionCommand(entryID: String) { reportExcluded() }
    func runExtensionCommand(_ app: AppEntry, arguments: [String: String] = [:]) { reportExcluded() }
    func runDeepLink(_ link: ExtensionDeepLink) { reportExcluded() }
    func showStoreInstall(_ install: ExtensionDeepLink.StoreInstall) { reportExcluded() }
    func showExtensionSettings(for app: AppEntry) {}
    func confirmUninstall(_ app: AppEntry) {}
    func removeExtensionReferences(entryIDs: [String]) {}
    func commandArguments(for entry: AppEntry?) -> [ExtensionCommandArgument]? { nil }
    func exitExtensionScreen() {}

    private func reportExcluded() {
        core.showMessage(ExcludedFeature.message("Raycast Extensions"), tone: .danger)
    }
}

/// Unreachable: `.extensionCommand` is only entered by running a command, which nothing can.
struct ExtensionCommandScreen: PaletteScreen {
    let screen: ExtensionScreen
    let extensions: ExtensionManager
    let vm: PaletteState
    let openActions: () -> Void

    var rows: [ExtensionScreen.Item] { [] }
    var primaryActionTitle: String { "" }
    var searchAccessory: ExtensionSearchAccessory? { nil }

    func activate(at selection: Int) {}
    func secondary(at selection: Int) -> Bool { false }
    func body(selection: Int, scroll: ScrollIntent) -> AnyView { AnyView(EmptyView()) }

    func searchAccessoryButton(
        _ accessory: ExtensionSearchAccessory, isOpen: Bool, action: @escaping () -> Void
    ) -> AnyView {
        AnyView(EmptyView())
    }

    func searchAccessoryMenu(
        searchQuery: ActionMenuSearchQuery, menuSelection: Binding<Int>,
        onActivate: @escaping (Int) -> Void
    ) -> PaletteMenuContent? {
        nil
    }
}

enum ExtensionArgumentsAccessory {
    static func make(
        entry: AppEntry?, coordinator: ExtensionCoordinator,
        values: @escaping (String) -> Binding<String>, focus: FocusState<String?>.Binding,
        metrics: InterfaceMetrics, onSubmit: @escaping () -> Void
    ) -> PaletteHeaderAccessory? {
        nil
    }
}

struct ExtensionRefreshIndicator: View {
    let state: ExtensionRefreshState
    var body: some View { EmptyView() }
}

struct ExtensionSelectionForwarder: ViewModifier {
    let screen: ExtensionScreen
    let selection: Int
    func body(content: Content) -> some View { content }
}

struct ExtensionShortcutKeys: ViewModifier {
    let screen: ExtensionCommandScreen?
    let selection: Int
    func body(content: Content) -> some View { content }
}

struct ExtensionToastSlot: ViewModifier {
    let extensions: ExtensionManager
    let showing: Bool
    func body(content: Content) -> some View { content }
}

struct ExtensionsSettingsView: View {
    var body: some View {
        ExcludedFeaturePane(feature: "Raycast Extensions", symbol: "puzzlepiece.extension")
    }
}
