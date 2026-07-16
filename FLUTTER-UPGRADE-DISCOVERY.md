# Flutter Upgrade Discovery Audit — Cosmic Facts

> **Type:** READ-ONLY discovery audit. No code, config, dependency, or lockfile was modified. No `pub upgrade`/`pub get` was run.
> **Date:** 2026-07-16
> **App:** `cosmic_facts` v1.4.0+5 (`pubspec.yaml:4`) · package `com.cosmicfacts.app`
> **Reference stable (verified live):** Flutter **3.44.3** / Dart **3.12.2**, released 2026-06-22 ([flutterreleases.com](https://flutterreleases.com/release/3.44.3/), [dart.dev](https://dart.dev/blog/announcing-dart-3-12)).
> **Installed toolchain (measured):** Flutter **3.41.2** stable / Dart **3.11.0** (`flutter --version`, 2026-02-18 build).

---

## Step 0 — What the app is (read from `features.md`)

Cosmic Facts is a large single-developer **Android-first space-knowledge/discovery app** (50+ features, ~108 Dart files, ~37k LOC per the in-repo `audit_report.md`/`refactor_audit.md`). `README.md` is the default Flutter template stub; the real feature doc is **`features.md`** (1000+ lines). Major feature areas:

- **Live NASA/space data** — APOD, NEO asteroids, NASA Image Library, EPIC (Earth), Spaceflight News, SpaceX launches, Open-Notify ISS, Exoplanet Archive, NOAA space weather, Open-Meteo (stargazing). All via `http` + a cache-first `Hive` layer (`features.md:633-644`).
- **3D / WebView experiences** — Solar System, Spacecraft Tracker, Historic Missions 3D (Three.js via `flutter_inappwebview`) (`features.md:780-872`).
- **AR Sky Map** — camera overlay + `sensors_plus` + `flutter_compass` + `geolocator` astronomy math (`features.md:814-828`).
- **Maps** — ISS tracker uses `flutter_map` + CartoDB tiles (`features.md:349-355`).
- **Media** — NASA audio via `audioplayers` (`features.md:462-469`).
- **Notifications** — local (`flutter_local_notifications` + `timezone`) *and* push (`firebase_messaging`); analytics + crash reporting (`firebase_analytics`, `firebase_crashlytics`) (`features.md:492-502`, `main.dart:8-10`).
- **Offline systems** — `Hive` for bookmarks, quiz/learn progress, achievements, observation log, caches (`main.dart:70-80`).
- **State management** — **GetX** (`GetMaterialApp`, `.obs`/controllers) (`main.dart:238`, `pubspec.yaml:16`).

Every risky upgrade below is mapped back to these areas in **§7 Feature-risk map**.

---

## 1. Executive summary

**This is an incremental modernization, NOT a large migration.** The project is fully null-safe (Dart 3.11, `environment: sdk: ^3.11.0` at `pubspec.yaml:7`; **zero `// @dart=` opt-outs** in `lib/`), on **Material 3** (`useMaterial3: true` at `app_theme.dart:131,258`), with Android already on **embedding v2** (`AndroidManifest.xml:44-45`) and iOS already migrated to the **new UIScene lifecycle** (`AppDelegate.swift:5,13-15` + `SceneDelegate.swift` + `Info.plist:29-49`). `flutter analyze` reports **"No issues found!"** and the codebase has **0 `.withOpacity(`** calls and none of the classic dead APIs (`WillPopScope`, `RaisedButton`/`FlatButton`, `accentColor`, old `TextTheme` names).

The SDK gap is small: Flutter 3.41.2 → 3.44.3 is **3 minor versions**; Dart 3.11 → 3.12 is **1 minor**. There is no null-safety migration and no v1-embedding migration to do — those large risks are absent.

**The real work is dependency debt.** Per `flutter pub outdated`, **~17 direct dependencies have a MAJOR (breaking) version available**, and 34 are lock-pinned behind their resolvable versions. The single biggest risk cluster is **Firebase / FlutterFire** (core 3→4, crashlytics 4→5, messaging 15→16, analytics 11→12) — these four must move together and can raise the iOS deployment target. Second is a set of independently-breaking plugins (`geolocator` 11→14, `sensors_plus` 4→7, `permission_handler` 11→12, `fl_chart` 0.68→1.2, `flutter_local_notifications` 18→22).

Two secondary risks: **toolchain version drift** — `android/local.properties:2` points at a *different* Flutter SDK (`3.38.5`) than the CLI on PATH (`3.41.2`), and `features.md:16` claims `3.41.3` — three different numbers; and **iOS has never been pod-installed** (no `ios/Podfile` or `Podfile.lock` exist), so the plugin set has never been linked on iOS.

### Ranked top 5 upgrade priorities

| # | Priority | Risk | Why |
|---|----------|------|-----|
| 1 | **Flutter/Dart SDK 3.41.2 → 3.44.3 (via fvm-pinned toolchain)** | **Low–Med** | Small gap, no null-safety/embedding work. Do FIRST so new deprecation warnings surface. Fix the `local.properties` vs CLI vs doc version drift as part of this. |
| 2 | **Firebase / FlutterFire coordinated bump (4 packages + android firebase-bom + iOS deploy target)** | **High** | Breaks push/analytics/crash telemetry if mismatched; `firebase_core 4.x` typically raises min iOS to 15+. Must move as one atomic set. |
| 3 | **Breaking single-plugin bumps: `geolocator` 11→14, `sensors_plus` 4→7, `permission_handler` 11→12, `flutter_local_notifications` 18→22** | **Med–High** | Each spans multiple majors with permission/API changes. Touch AR Sky Map, stargazing, ISS map, and the entire notification system. |
| 4 | **`fl_chart` 0.68 → 1.2** | **Med** | The 0.68→1.0 line was a hard API break (chart data/painter classes renamed). Isolated to chart screens — easy to test, but not mechanical. |
| 5 | **Leaf/low-risk bumps + `build_runner` un-pin (2.4.13 → 2.15.x) to drop discontinued transitives** | **Low** | `google_fonts` 6→8, `share_plus` 12→13, `flutter_map` 7→8, `flutter_dotenv` 5→6, `smooth_page_indicator` 1→2, `camera` 0.10→0.12, `flutter_timezone` 3→5, `xml` 6→7. `build_runner` pin at `pubspec.yaml:55` forces the **discontinued** `build_resolvers`/`build_runner_core`. |

---

## 2. Version gap table

| Area | Current | Latest / Target | Gap | Breaking? |
|------|---------|-----------------|-----|-----------|
| Flutter (CLI) | 3.41.2 stable | 3.44.3 stable | 3 minor | No (incremental) |
| Dart | 3.11.0 | 3.12.2 | 1 minor | No |
| Flutter (in `local.properties`) | **3.38.5** (`local.properties:2`) | — | drift vs CLI & doc | ⚠ config drift |
| Null safety | Sound (Dart 3, 0 opt-outs) | — | none | ✅ done |
| Material | M3 (`useMaterial3: true`) | M3 | none | ✅ done |
| Android embedding | v2 (`AndroidManifest.xml:45`) | v2 | none | ✅ done |
| iOS lifecycle | UIScene (migrated) | UIScene | none | ✅ done |
| AGP (Android Gradle Plugin) | 8.11.1 (`settings.gradle.kts:23`) | ~8.13 line | patch/minor | No |
| Gradle wrapper | 8.14 (`gradle-wrapper.properties:5`) | ~8.14+ | current | No |
| Kotlin | 2.2.20 (`settings.gradle.kts:24`) | current 2.2.x | none | No |
| Java / JVM target | 17 (`app/build.gradle.kts:26-27,32`) | 17 | none | ✅ meets Play mandate |
| compileSdk / targetSdk | delegated to `flutter.*` (`app/build.gradle.kts:21,49`); doc claims **36 / 36** (`features.md:15-16`) | 36 | ⚠ confirm at build | No if 36 |
| minSdk | delegated to `flutter.minSdkVersion` (`app/build.gradle.kts:48`); doc claims **24** (`features.md:14`), launcher-icons config says 21 (`pubspec.yaml:64`) | — | ⚠ confirm at build | No |
| iOS deployment target | 13.0 (`project.pbxproj:353,479,530`) | 13.0 ok now; Firebase 4 may force 15+ | possible bump | ⚠ dep-driven |
| Swift | 5.0 (`project.pbxproj:378…`) | 5.x | fine | No |
| Lints | `flutter_lints ^6.0.0` (`pubspec.yaml:52`) | 6.x | current | No |
| **Key deps (MAJOR available)** | see §3 | | | **Yes ×17** |

---

## 3. Dependency table

Source: `flutter pub outdated` (captured read-only). "Current" = resolved in `pubspec.lock`; "Resolvable" is capped by the caret constraints in `pubspec.yaml`, so most MAJOR jumps require editing `pubspec.yaml` (i.e. `pub upgrade --major-versions` — **not run here**). **All dependencies are hosted on pub.dev — no `git:`/`path:` sources** (verified in `pubspec.lock`).

### Direct dependencies

| Package | Current | Latest | Jump | Discontinued? | Breaking notes | Blocks / touches |
|---------|---------|--------|------|---------------|----------------|------------------|
| firebase_core | 3.15.2 | **4.12.1** | MAJOR | no | Must bump with all firebase_* together; may raise min iOS to 15+ and android firebase-bom | Push, analytics, crash (`main.dart:89`) |
| firebase_crashlytics | 4.3.10 | **5.2.6** | MAJOR | no | Coupled to firebase_core 4 | Crash reporting (`main.dart:167`) |
| firebase_messaging | 15.2.10 | **16.4.3** | MAJOR | no | Coupled to firebase_core 4 | Push (`firebase_notification_service.dart`) |
| firebase_analytics | 11.6.0 | **12.4.5** | MAJOR | no | Coupled to firebase_core 4 | Screen-view logging (`main.dart:231`) |
| geolocator | 11.1.0 | **14.0.3** | MAJOR ×3 | no | Location API + Android permission changes across 12/13/14 | AR Sky Map, Stargazing forecast |
| sensors_plus | 4.0.2 | **7.1.0** | MAJOR ×3 | no | Stream API reshaped across majors | AR Sky Map orientation |
| permission_handler | 11.4.0 | **12.0.3** | MAJOR | no | Android 14/15 permission model; targetSdk-sensitive | Camera + location prompts |
| flutter_local_notifications | 18.0.1 | **22.0.1** | MAJOR ×4 | no | Repeated API + Android exact-alarm/channel changes; needs desugaring (already on, `app/build.gradle.kts:25,78`) | Entire local-notification system |
| fl_chart | 0.68.0 | **1.2.0** | MAJOR | no | 0.68→1.0 renamed chart data/painter classes — hard break | Chart/graph screens |
| google_fonts | 6.3.3 | **8.2.0** | MAJOR ×2 | no | Font-fetch/caching API changes | App-wide typography (Space Grotesk/Inter) |
| share_plus | 12.0.1 | **13.2.1** | MAJOR | no | `Share.share` → `SharePlus.instance.share(ShareParams)` API change | Every share button |
| flutter_map | 7.0.2 | **8.3.1** | MAJOR | no | Layer/options API churn 7→8 | ISS tracker map |
| flutter_dotenv | 5.2.1 | **6.0.1** | MAJOR | no | Minor API/load change | `.env` / API keys (`main.dart:53`) |
| flutter_timezone | 3.0.1 | **5.1.0** | MAJOR ×2 | no | Return-type/API changes | Notification scheduling tz |
| smooth_page_indicator | 1.2.1 | **2.0.1** | MAJOR | no | Effect/constructor API changes | Onboarding page dots |
| camera | 0.10.6 | **0.12.0+2** | MAJOR (0.x) | no | Platform impl swap; resolvable already jumps to 0.12 | AR Sky Map camera |
| xml | 6.6.1 | **7.0.1** | MAJOR | no | Parser API; resolvable stays 6.6.1 (constraint-capped) | Arxiv/RSS parsing in `api_service` |
| timezone | 0.9.4 | **0.11.1** | MINOR (0.x, breaking-ish) | no | Data/API tweaks; move with flutter_timezone | Notifications |
| latlong2 | 0.9.1 | **0.10.1** | MINOR (0.x) | no | Small | flutter_map coordinates |
| audioplayers | 6.6.0 | 6.8.1 | minor | no | Non-breaking | Space sounds |
| path_provider | 2.1.5 | 2.1.6 | patch | no | Safe | Hive/cache paths |
| cupertino_icons | 1.0.8 | 1.0.9 | patch | no | Safe | Icons |
| intl | 0.20.2 | 0.20.3 | patch | no | Safe | Date/number formatting |
| get (GetX) | 4.7.2 | 4.7.2 | **current** | no | No stable 5.x yet — no action | State mgmt + navigation (whole app) |
| hive / hive_flutter | 2.2.3 / 1.1.0 | current 2.x | current | no (maintenance) | Original `hive` is low-activity; community fork `hive_ce` exists — optional future migration, not required | All offline storage |

### Dev dependencies

| Package | Current | Latest | Jump | Notes |
|---------|---------|--------|------|-------|
| build_runner | **2.4.13 (pinned exact, `pubspec.yaml:55`)** | 2.15.2 | minor, but **pin blocks it** | The exact pin forces old transitives → pulls **discontinued** `build_resolvers` and `build_runner_core` (see below). Un-pin to `^2.15.0`. |
| hive_generator | 2.0.1 | 2.x | current | Compatible with Hive 2.x; codegen for `ObservationLogAdapter` (`main.dart:62`) |
| flutter_lints | 6.0.0 | 6.x | current | ✅ modern |
| flutter_launcher_icons | 0.14.0 | 0.14.x | current | Build-time only |
| flutter_native_splash | 2.4.7 | 2.4.8 | patch | Safe |
| flutter_test | sdk | — | — | Follows SDK |

### Discontinued transitive packages (evidence: `flutter pub outdated` footer)

- **`build_resolvers`** — "has been discontinued" (transitive via pinned `build_runner`).
- **`build_runner_core`** — "has been discontinued" (transitive via pinned `build_runner`).

Both disappear when `build_runner` is un-pinned/bumped (they were folded into the `build` package). No direct dependency is discontinued.

### Codegen + state-management coordination note
Codegen chain = `build_runner` (dev) + `hive_generator` (dev) generating Hive type adapters. Bump these **together** and re-run `dart run build_runner build` after the SDK bump. State management is **GetX 4.7.2 (latest)** — no bump needed; GetX 5 is still pre-stable, so it is *not* on the critical path.

---

## 4. Platform build findings

### Android — healthy and modern (evidence)

| Item | Value | Evidence |
|------|-------|----------|
| AGP | 8.11.1 | `android/settings.gradle.kts:23` |
| Kotlin | 2.2.20 | `android/settings.gradle.kts:24` |
| google-services plugin | 4.4.2 | `android/settings.gradle.kts:25` |
| firebase-crashlytics gradle plugin | 3.0.2 | `android/settings.gradle.kts:26` |
| Gradle wrapper | 8.14 | `android/gradle/wrapper/gradle-wrapper.properties:5` |
| Java source/target + jvmTarget | 17 / 17 | `android/app/build.gradle.kts:26-27,32` |
| `namespace` (AGP 8 requirement) | `com.cosmicfacts.app` present | `android/app/build.gradle.kts:20` |
| Build script language | **Kotlin DSL** (`.kts`) | `build.gradle.kts`, `settings.gradle.kts` |
| Embedding | **v2** | `AndroidManifest.xml:44-45` (`flutterEmbedding` = `2`) |
| Core-library desugaring | enabled + `desugar_jdk_libs:2.1.4` | `android/app/build.gradle.kts:25,78` (required by flutter_local_notifications) |
| 16KB alignment | `useLegacyPackaging = false` | `android/app/build.gradle.kts:70-74` (+ doc `features.md:601-607`) |
| Firebase BOM | 33.7.0 | `android/app/build.gradle.kts:79` |
| compile/target/minSdk | delegated to `flutter.*` | `android/app/build.gradle.kts:21,48-49` |

**Android verdict:** essentially up to date. No embedding migration, namespace present, Java 17, Kotlin DSL, 16KB-friendly. Minor cleanups only:
- `android.enableJetifier=true` (`gradle.properties:3`) is legacy (all deps are AndroidX) — likely removable.
- `android.nonTransitiveRClass=false` and `android.nonFinalResIds=false` (`gradle.properties:5-6`) are set to the pre-AGP-8 defaults; flipping to `true` is a minor modernization.
- Firebase BOM 33.7.0 (`build.gradle.kts:79`) should be re-verified against whatever `firebase_core 4.x` expects when Priority 2 runs.
- **Play compliance:** Java 17 met; 16KB met per config; targetSdk 36 (doc) satisfies the Play targetSdk mandate — **confirm actual `flutter.targetSdkVersion` resolves to 36 at build** (it is not literally in the gradle file).

### iOS — modern lifecycle, but never pod-installed (evidence)

| Item | Value | Evidence |
|------|-------|----------|
| **Podfile / Podfile.lock** | **ABSENT** | no file in `ios/` (glob of `ios/**/*`) — CocoaPods never initialized; plugin set never linked on iOS |
| Deployment target | iOS **13.0** | `ios/Runner.xcodeproj/project.pbxproj:353,479,530` |
| Swift version | 5.0 | `ios/Runner.xcodeproj/project.pbxproj:378,395,410,425,558,579` |
| Xcode project format | objectVersion 54; LastUpgradeCheck 1510 (Xcode 15.1) | `project.pbxproj:6,174` |
| **UIScene lifecycle** | **already migrated** | `AppDelegate.swift:5` (`FlutterImplicitEngineDelegate`), `:13-15` (`didInitializeImplicitFlutterEngine`), `SceneDelegate.swift` present, `Info.plist:29-49` (`UIApplicationSceneManifest`) |

**iOS verdict:** The Flutter-3.38+ UIScene migration is **done** — no AppDelegate/lifecycle work needed. The real gaps are: (1) **no Podfile has ever been generated**, so an iOS build is unproven with this plugin set (Firebase, camera, geolocator, sensors, inappwebview all have iOS pods); (2) deployment target **13.0** is fine today but `firebase_core 4.x` / recent Firebase iOS SDKs commonly require **iOS 15+**, so Priority 2 may force a bump here. Both are **NEEDS-BUILD** items.

---

## 5. Deprecated / removed-API findings

**Headline: the Dart code is already clean against Flutter 3.41.** `flutter analyze` → **"No issues found! (ran in 6.2s)"**, which includes deprecation (`deprecated_member_use`) diagnostics. Grep confirms none of the classic offenders exist.

| API / pattern | Occurrences | Evidence | Replacement | Class |
|---------------|-------------|----------|-------------|-------|
| `.withOpacity(` | **0** | grep `lib/` | `.withValues(alpha:)` — already done | ✅ none |
| `WillPopScope` | 0 | grep | `PopScope` | ✅ none |
| `RaisedButton`/`FlatButton`/`OutlineButton` | 0 | grep | Elevated/Text/Outlined | ✅ none |
| `ThemeData.accentColor` | 0 | grep | `colorScheme.secondary` | ✅ none |
| Old `TextTheme` names (`headline*`, `bodyText*`, `subtitle*`, `caption`) | 0 | grep | `titleLarge`/`bodyMedium`/… | ✅ none |
| `resizeToAvoidBottomPadding` | 0 | grep | `resizeToAvoidBottomInset` | ✅ none |
| `Color.value` / component getters | 0 (all `.value` hits are GetX `.obs`) | grep across `controllers/`, `main.dart:243` | n/a | ✅ none |
| `useMaterial3` | set `true` in both themes | `theme/app_theme.dart:131,258` | — (already M3) | ✅ none |
| `MediaQuery.of(context).size` / `.padding` / `.viewInsets` | 16 across 11 files | e.g. `iss_tracker_screen.dart:122`, `earth_from_space_screen.dart:329,1041`, `home_screen.dart:1521`, `ar_sky_map_screen.dart:180,470,607` | `MediaQuery.sizeOf/paddingOf/viewInsetsOf(context)` | **Mechanical, optional** (perf, not deprecated) |

**Grouping:**
- **Mechanical (find/replace-ish):** only the `MediaQuery.of(context).X` → `.Xof(context)` perf modernization (16 sites). Not required for the upgrade — it's a rebuild-scope optimization, not a deprecation.
- **Needs judgment:** none currently in-code.

⚠ **Caveat (NEEDS-BUILD):** `flutter analyze` was run under **3.41**, so it only proves cleanliness against 3.41's deprecation set. APIs **newly deprecated in 3.42–3.44** will not surface until the SDK is bumped. Re-run `flutter analyze` immediately after Wave 1 to get the true 3.44 deprecation list — that is where any real deprecated-API cleanup will appear.

### Analyzer / lint summary
- `flutter analyze`: **0 errors, 0 warnings, 0 info** (`No issues found!`).
- Lint set: `include: package:flutter_lints/flutter.yaml` (`analysis_options.yaml:10`), dependency `flutter_lints ^6.0.0` (`pubspec.yaml:52`) — current major, no custom rule overrides. Modern and healthy.

---

## 6. Ordered upgrade plan (THE KEY DELIVERABLE)

Waves are ordered so each rests on a green build from the one before. **Wave 0 and 1 are strictly sequential and gate everything.** Within Wave 2, the sub-groups are largely independent of each other (parallelizable) *except* the Firebase cluster, which is atomic.

### Wave 0 — Prep & tooling (Low risk, do first, blocks all)
- **Fix toolchain drift.** Reconcile the three Flutter versions: CLI `3.41.2`, `android/local.properties:2` = `3.38.5`, `features.md:16` = `3.41.3`. Pin one known-good SDK via **fvm** (`.fvmrc`) so CI and every dev use the same engine. (No null-safety prep needed — already sound.)
- **Baseline capture:** record current `flutter analyze` (clean), a release AAB build, and `pubspec.lock` in version control before touching anything.
- **Un-pin `build_runner`** intent: note `pubspec.yaml:55` is `build_runner: 2.4.13` (exact). Plan to change to `^2.15.0` in Wave 2 to drop discontinued `build_resolvers`/`build_runner_core`.
- **Verify:** `flutter --version` == fvm-pinned; clean `git status`; AAB builds.

### Wave 1 — SDK bump 3.41.2 → 3.44.3 / Dart 3.11 → 3.12 (Low–Med, sequential)
- The gap is only 3 minor versions, so a **single step to 3.44.3 is acceptable** (no need to hop through intermediates — there is no null-safety or embedding cliff between them).
- After bump: **re-run `flutter analyze`** — this is the moment new 3.42–3.44 deprecation warnings appear. Triage them here (expect them to be few/mechanical given the code's current cleanliness).
- **Verify:** `flutter analyze` clean or only-known deprecations; `flutter test`; debug run on Android; **first-ever `flutter build ios --no-codesign`** to force Podfile generation and prove the iOS toolchain (still on old deps).
- *Independent of Wave 2 dependency work — but must precede it (newer plugins will demand the newer SDK; lock says deps already require `flutter >=3.38.4`).*

### Wave 2 — Dependencies, in dependency-safe order (mixed risk)
Do leaf/low-risk first to keep the tree resolvable, then the breaking clusters. Each sub-group = its own PR + green build.

1. **2a — Safe bumps (Low):** `audioplayers`, `path_provider`, `cupertino_icons`, `intl`, `flutter_native_splash`. Pure patch/minor.
2. **2b — Codegen (Low):** un-pin `build_runner` → `^2.15.x`, keep `hive_generator` in step, `dart run build_runner build --delete-conflicting-outputs`. Confirms discontinued transitives are gone.
3. **2c — Independent breaking plugins (Med–High), one PR each so failures isolate:**
   - `fl_chart` 0.68 → 1.2 (chart API rewrite)
   - `share_plus` 12 → 13 (`ShareParams` API)
   - `google_fonts` 6 → 8
   - `smooth_page_indicator` 1 → 2 (onboarding)
   - `flutter_map` 7 → 8 (+ `latlong2` 0.9 → 0.10 together)
   - `camera` 0.10 → 0.12
   - `flutter_dotenv` 5 → 6
   - `xml` 6 → 7
4. **2d — Sensor/permission/notification cluster (Med–High):** `permission_handler` 11 → 12 first (others depend on the permission model), then `geolocator` 11 → 14 and `sensors_plus` 4 → 7 (AR Sky Map + stargazing), then `flutter_local_notifications` 18 → 22 with `flutter_timezone` 3 → 5 + `timezone` 0.9 → 0.11 **together** (scheduling depends on tz types).
5. **2e — Firebase / FlutterFire (HIGH, ATOMIC):** bump `firebase_core` 3→4, `firebase_crashlytics` 4→5, `firebase_messaging` 15→16, `firebase_analytics` 11→12 **in a single change**, and re-align the android `firebase-bom` (`app/build.gradle.kts:79`). This is the highest-risk PR — do it **after** everything else is green so it's the only moving part.
- **Verify each sub-group:** `flutter pub get` resolves; `flutter analyze`; `flutter test`; run the specific feature (chart screen, share sheet, map, camera, notification schedule, push token, crash test event).

### Wave 3 — Android build config (Low, mostly already done)
- Only cleanups remain: consider removing `enableJetifier` and flipping `nonTransitiveRClass`/`nonFinalResIds` to `true` (`gradle.properties:3,5-6`); re-confirm `firebase-bom` version post-Wave-2e; nudge AGP/Gradle to the newest patch that the 3.44 tool blesses.
- **Verify:** release AAB builds; `flutter build appbundle`; confirm targetSdk resolves to 36.

### Wave 4 — iOS build config (Med, NEEDS-BUILD — highest unknown)
- Generate/commit `Podfile` + `Podfile.lock` (first ever). `pod install` after Wave 2. **Raise `IPHONEOS_DEPLOYMENT_TARGET` if `firebase_core 4.x` demands 15+** (`project.pbxproj:353,479,530`).
- No UIScene work — already migrated.
- **Verify:** `flutter build ipa` (or `--no-codesign`) on macOS; smoke-test push, camera, location, share on a real device/simulator.

### Wave 5 — Deprecated-API cleanup + polish (Low)
- Address whatever `flutter analyze` surfaced in Wave 1 under 3.44.
- Optional mechanical pass: `MediaQuery.of(context).X` → `.Xof(context)` (16 sites, §5).
- Material 3 is already on — nothing to migrate.

**Independent vs sequential:** Wave 0 → 1 → 2 → 3/4 → 5 are sequential gates. **Within Wave 2, sub-groups 2a–2d are independent of each other** and can be parallelized across branches; **2e (Firebase) is atomic and should be last.** Wave 3 (Android) and Wave 4 (iOS) are independent of each other and can proceed in parallel once Wave 2 is green.

---

## 7. Feature-risk map

| Feature (from `features.md`) | Upgrades that touch it | What could break | Verify |
|------|------|------|------|
| **Push notifications / analytics / crash** (`main.dart:8-10,89,167,231`) | Firebase cluster 2e (core 3→4, msg 15→16, analytics 11→12, crashlytics 4→5) + android firebase-bom + iOS deploy target | Init throws `[core/no-app]`, missing FCM token, screen_view logging silently stops, crash upload breaks | Cold-start on real device; force a test crash; confirm token + a `screen_view` event in console |
| **Local notifications** (daily fact/APOD/quiz/launch/asteroid alerts, `features.md:492-502`; `notification_service.dart`) | `flutter_local_notifications` 18→22 + `flutter_timezone` 3→5 + `timezone` 0.9→0.11 (2d) | Scheduling API changes; exact-alarm/channel behavior on Android 14+; tz type mismatch | Schedule + fire each notification type; check boot-persistence (`AndroidManifest.xml:52-57`) |
| **AR Sky Map** (`features.md:814-828`) | `sensors_plus` 4→7, `geolocator` 11→14, `permission_handler` 11→12, `camera` 0.10→0.12 (2c/2d) | Orientation stream API reshape; location permission model; camera platform swap; permission prompts | Live camera overlay + compass + star identification on device; permission flows |
| **Stargazing forecast** (`features.md:916-934`; `weather_service.dart`) | `geolocator` 11→14 (2d) | Position API change | Score computed from current GPS location |
| **ISS tracker map** (`features.md:349-355`) | `flutter_map` 7→8 + `latlong2` (2c) | Layer/options API break; tile rendering | Map loads CartoDB tiles, ISS dot moves |
| **Charts / graphs** | `fl_chart` 0.68→1.2 (2c) | Renamed chart/data/painter classes — compile break | Every screen with a chart renders |
| **Share (articles, images, APOD, quiz score, launches)** (`features.md:83,206,284…`) | `share_plus` 12→13 (2c) | `Share.share(...)` → `SharePlus.instance.share(ShareParams(...))` | Each share button opens native sheet |
| **Typography (whole app)** — Space Grotesk / Inter | `google_fonts` 6→8 (2c) | Font fetch/cache API change; possible first-run font flash | Text renders correct fonts online + offline |
| **Onboarding** page dots (`features.md:33-38`) | `smooth_page_indicator` 1→2 (2c) | Effect/constructor API change | 3-step onboarding indicator animates |
| **API keys / .env** (`main.dart:53`; `api_keys.dart`) | `flutter_dotenv` 5→6 (2c) | `.env` load/lookup API change | Keys load; DEMO_KEY fallback still works |
| **NASA audio (Space Sounds)** (`features.md:462-469`) | `audioplayers` 6.6→6.8 (2a, minor) | Low risk | Play/pause a sound |
| **Arxiv/RSS parsing** (`api_service.dart`) | `xml` 6→7 (2c) | Parser API change | Space research papers parse |
| **Offline storage** (bookmarks, progress, caches, observation log) (`main.dart:70-80`) | `build_runner`/`hive_generator` (2b); Hive stays 2.x | Adapter regen mismatch if codegen skipped | Data persists across restart; `ObservationLogAdapter` regenerates |
| **3D WebViews** (Solar System, Spacecraft, Missions) (`features.md:780-872`) | `flutter_inappwebview` **not** flagged outdated — no bump | Low (only affected indirectly by SDK bump) | 3D scenes load + interact after Wave 1 |
| **State mgmt + navigation (entire app)** | GetX — **no bump** (at latest) | none | n/a |

---

## 8. What I could NOT determine (blind spots)

1. **Actual resolved `compileSdk`/`targetSdk`/`minSdk`.** The gradle file delegates to `flutter.compileSdkVersion`/`targetSdkVersion`/`minSdkVersion` (`app/build.gradle.kts:21,48-49`); the concrete integers are supplied by the Flutter tool at build time. `features.md:14-16` claims 36/36/24 and `pubspec.yaml:64` says `min_sdk_android: 21`. **Confirm with a build** (`flutter build appbundle` + inspect merged manifest) — not provable from files alone.
2. **iOS build viability.** No `Podfile`/`Podfile.lock` has ever existed, so the plugin set (Firebase, camera, geolocator, sensors_plus, inappwebview, audioplayers) has **never been linked/compiled on iOS**. Whether it builds — and the exact deployment target Firebase 4 forces — can only be learned by running `flutter build ios` on macOS.
3. **Post-3.44 deprecations.** `flutter analyze` was clean under 3.41 only. The true deprecated-API list for 3.44 appears **only after Wave 1**. I cannot enumerate it now without the newer SDK.
4. **Runtime behavior of the MAJOR dep bumps.** Compile-clean ≠ behavior-clean. `fl_chart` 1.x rendering, `share_plus` 13 sheet behavior, `flutter_local_notifications` 22 exact-alarm scheduling on Android 14+, `geolocator` 14 permission flow, and the Firebase 4 init path can only be validated by running the features on real devices (Android + iOS).
5. **`flutter_inappwebview` future compatibility.** It is not flagged by `flutter pub outdated` (already at its resolvable version), but the three 3D WebView features depend heavily on it; its behavior under the 3.44 engine is a **NEEDS-RUNTIME** check.
6. **Firebase Android BOM alignment.** Whether `firebase-bom 33.7.0` (`app/build.gradle.kts:79`) is compatible with `firebase_core 4.x`, or needs its own bump, is only knowable when Wave 2e is attempted and the build resolves.

---

*Report generated read-only. The only file created is this deliverable (`FLUTTER-UPGRADE-DISCOVERY.md`). No source, config, dependency, or lockfile was modified; no `pub get`/`pub upgrade` was run.*

**Sources for the live version reference:** [Flutter 3.44.3 — Dart 3.12.2 (flutterreleases.com)](https://flutterreleases.com/release/3.44.3/) · [Announcing Dart 3.12 (dart.dev)](https://dart.dev/blog/announcing-dart-3-12) · [Flutter release notes](https://docs.flutter.dev/release/release-notes)
