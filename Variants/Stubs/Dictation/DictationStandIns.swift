import SwiftUI

// Stand-ins for Features/Dictation/{Service,UI,Settings}: the surface the rest of the app calls.

@MainActor
final class DictationAudioDucker {
    func recover() {}
    func restoreImmediately() {}
    func waitForTransition() async {}
}

@MainActor
@Observable
final class DictationModelStore {
    init(idleRelease: DictationIdleRelease) {}
    func isInstalled(_ model: DictationModel) -> Bool { false }
    func setIdleRelease(_ option: DictationIdleRelease) {}
    func stop() async {}
}

/// Which editor a mic session belongs to; never set, since nothing here records.
struct DictationField: Equatable {
    let editor: ObjectIdentifier
    var isTranscribing = false
}

@MainActor
@Observable
final class DictationCoordinator {
    let models: DictationModelStore
    private let showMessage: (String, DialogTone) -> Void
    private(set) var field: DictationField?

    init(
        settings: AppSettings, hotKeys: HotKeyManager, models: DictationModelStore,
        injector: TextInjector, audioDucker: DictationAudioDucker,
        confirmEnable: @escaping () async -> Bool,
        showMessage: @escaping (String, DialogTone) -> Void
    ) {
        self.models = models
        self.showMessage = showMessage
    }

    /// False even when the preference says on, so no mic button or panel ever appears.
    var isEnabled: Bool { false }
    var hasModel: Bool { false }

    func pressed() { showMessage(ExcludedFeature.message("Dictation"), .danger) }
    func released() {}
    func cancel() {}
    func cancel(in editor: any InjectableTextView) {}
    func toggle(into editor: any InjectableTextView) { pressed() }
    func prepareForTermination() {}
}

struct DictationSettingsView: View {
    var body: some View {
        ExcludedFeaturePane(feature: "Dictation", symbol: "waveform")
    }
}
