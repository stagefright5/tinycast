import Foundation

/// Like a real source with its feature off: it never speaks for its data, so none reads as deleted.
@MainActor
class ExcludedSyncSource: SyncSource {
    let id: SyncSourceID

    init(_ id: SyncSourceID) {
        self.id = id
    }

    func observe() {}
    func snapshot() async -> [String: String]? { nil }
    func payload(for key: String) async -> Data? { nil }

    func apply(_ changes: SyncChanges) async -> Set<String> {
        Set(changes.upserts.keys).union(changes.deletions)
    }
}

extension RecordSyncSource {
    /// `records` is nil, as the real sources report while their feature is off.
    static func excluded(_ id: SyncSourceID) -> Self {
        Self(id, records: { nil }, save: { _ in false }, remove: { _ in false }, isDuplicate: { _, _ in false })
    }
}
