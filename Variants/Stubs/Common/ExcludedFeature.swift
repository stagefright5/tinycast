import SwiftUI

/// The one wording every stand-in uses for a feature this variant compiled out.
enum ExcludedFeature {
    static func message(_ feature: String) -> String {
        "\(feature) isn't included in this build"
    }
}

/// What a Settings pane shows in place of a feature this variant compiled out.
struct ExcludedFeaturePane: View {
    let feature: String
    let symbol: String

    var body: some View {
        Form {
            Section {
                Label {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text(ExcludedFeature.message(feature)).font(.headline)
                        Text("This copy of Tinycast was built with Scripts/build-variant.sh. "
                            + "Build the full app to use it; its settings are kept.")
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                } icon: {
                    Image(systemName: symbol)
                }
            }
        }
        .formStyle(.grouped)
    }
}
