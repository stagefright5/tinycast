# Build variants

A local, out-of-tree way to build `Tinycast Dev.app` without whole features. Nothing here edits an
upstream file: the committed `Tinycast.xcodeproj` and ⌘R in Xcode still build the full app, and
`git pull --rebase origin main` on the `variants` branch never conflicts.

```sh
Scripts/build-variant.sh --without ai,extensions,dictation   # build, verify, test, install
Scripts/build-variant.sh --without extensions --no-install   # build and verify only
Scripts/build-variant.sh --check                             # all 8 combinations, no install
Scripts/build-variant.sh                                     # the full app, same pipeline
```

Needs Xcode (the SwiftUI macros are not in the Command Line Tools), `brew install xcodegen`, and node.

## What each flag removes

| Flag | Compiled out | Also dropped from the bundle |
| --- | --- | --- |
| `dictation` | `Features/Dictation/{Service,UI,Settings,Helper}` | the `Tinycast Dev Dictation.app` helper, `audio-input` entitlement, microphone usage string |
| `extensions` | `Features/Extensions/{Service,UI,Settings}`, `Model/ExtensionBootConfig.swift` | `RaycastRuntime.generated.js`, JavaScriptCore, the `allow-jit` entitlement, the `raycast://` and `com.raycast://` schemes, the Reminders usage string |
| `ai` | `Features/{AI,MCP,QuickActions}` except their `Model/` folders and settings stores | FoundationModels |

What stays compiled on purpose: each feature's `Model/` (inert value types the shared settings code
names, kept honest by the repo's no-AppKit/SwiftUI rule), `ExtensionScreen`, and the AI, MCP and
Quick Action settings stores. Because those stores are the real ones, preferences, `settings.json`
and backups round-trip exactly; no stand-in takes part in either.

## How it works

1. `xcodegen dump --type json` turns `project.yml` into a spec.
2. `Scripts/variant/make-spec.mjs` applies `Variants/features.json`: excludes, keeps, the stand-in
   folder, `TINYCAST_NO_<FEATURE>`, dropped helper targets, derived Info.plist and entitlements.
3. `xcodegen generate` writes `Tinycast-<variant>.xcodeproj` beside `project.yml` (its `SOURCE_ROOT`
   paths only resolve from there); `.git/info/exclude` keeps it out of git.
4. `xcodebuild` builds into `build/DerivedData`, the bundle is checked against `features.json`,
   `Scripts/run-tests.sh` runs, and the app is installed to `/Applications` with a backup in
   `build/install-backups/` and a record in `build/install-records/`.
5. Every other `Tinycast Dev.app` under `build/` is unregistered from LaunchServices, and `--check`
   deletes its products: they share the bundle id, so a fuller copy would otherwise answer a
   `raycast://` link with the installed app's preferences. Opening a backup in Finder registers it
   again; re-run the install, or `lsregister -u` that path.

`Stubs/<Feature>/` holds the stand-ins: the handful of types the rest of the app calls, with the same
signatures and no behaviour. Coordinators hide their launcher commands (so bound shortcuts stop
firing) and any entry point that still fires shows "… isn't included in this build". Settings panes
show a placeholder. Stand-ins never write preferences, so a later full build finds everything as it was.

## After `git pull`

Run `Scripts/build-variant.sh --check`. When upstream changes an API the rest of the app calls on an
excluded feature, a slim combination fails with "cannot find …" or "no member …" pointing at the
exact call; add or adjust that member in `Stubs/<Feature>/`, matching the real signature. If a kept
`Model/` file starts calling into `Service/`, either stub that call or add the file to `exclude`.
