## v0.1.0 (21-10-2026)

### ♻️ Refactoring

- Replace magic numbers with theme tokens and named constants ([1ca21f4](https://github.com/swaiku/pigeon-finder/commit/1ca21f4726aeb604456a8ff27337b720b9527a7a))

### ✨ Features

- Add routing to the app to test it ([5bb7cda](https://github.com/swaiku/pigeon-finder/commit/5bb7cdaad3d0967fe2262442360d93752bc862df))
- Add map domain: posts, region levels, repository contract ([06a05b8](https://github.com/swaiku/pigeon-finder/commit/06a05b8123ec0b6e7749183874f54aca5f1a23fe))
- Add location and region data sources with a fake repository ([d90a0b8](https://github.com/swaiku/pigeon-finder/commit/d90a0b8bad5142d1bc74fd9523ece7a83be943a1))
- Add MapBloc with region lookup and live user position ([946f847](https://github.com/swaiku/pigeon-finder/commit/946f847fc5cf9aabce665db28f4bee056f3e9c94))
- Add map widgets: header, buttons, post card, pin, OSM tiles ([1f393a5](https://github.com/swaiku/pigeon-finder/commit/1f393a5fbac9468efd9578eda40fe0f25abe8c1f))
- Cluster pins and show a heat map when zoomed out ([654447f](https://github.com/swaiku/pigeon-finder/commit/654447f7f1ea07f0a71814a5ad6d36140bcae123))
- Wire up the map page ([47f5b19](https://github.com/swaiku/pigeon-finder/commit/47f5b19779b4f3c02da092416d26d3be07958d3b))
- Add animated post detail sheet with report popup ([39ae922](https://github.com/swaiku/pigeon-finder/commit/39ae922697a4d8e9de66cc76ada4008e7276e667))
- Show the post photo in map pins and the detail sheet ([2e628d1](https://github.com/swaiku/pigeon-finder/commit/2e628d118b34738e60e8af5310e2e4f4d1696e0c))
- Count pigeons in the visible map area in the header ([676dd5c](https://github.com/swaiku/pigeon-finder/commit/676dd5c073310c0363c348989550f8db29725417))

### 👷 CI

- add build of the apk with the develop branch ([9eb3456](https://github.com/swaiku/pigeon-finder/commit/9eb34566eeffed17bde3ebbdf4d52428ec4de10c))
- Bump actions/upload-artifact

Bumps the actions group with 1 update in the / directory: [actions/upload-artifact](https://github.com/actions/upload-artifact).


Updates `actions/upload-artifact` from 6 to 7
- [Release notes](https://github.com/actions/upload-artifact/releases)
- [Commits](https://github.com/actions/upload-artifact/compare/v6...v7)

---
updated-dependencies:
- dependency-name: actions/upload-artifact
  dependency-version: '7'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
...

Signed-off-by: dependabot[bot] <support@github.com> ([ddfeb50](https://github.com/swaiku/pigeon-finder/commit/ddfeb50dd7e1940e552fd48011b31bb49602f11f))

### 💄 UI & Style

- Make the user location dot red ([2c63cef](https://github.com/swaiku/pigeon-finder/commit/2c63cef67be862e0f13661fdb72bc30027f34090))

### 📝 Documentation

- Complete README with project description and features ([014fc21](https://github.com/swaiku/pigeon-finder/commit/014fc21351949f511d26669990d6e7b5fc01530b))
- Complete README with project description and features ([754f8ee](https://github.com/swaiku/pigeon-finder/commit/754f8ee66f96b53197f788d8e0f07ee0f9157b98))

### 📦 Build & Dependencies

- Add map dependencies and location permission ([960264b](https://github.com/swaiku/pigeon-finder/commit/960264bc0bec74f2ba81483570d9ef6ec60c1e44))
- Bump supabase_flutter (#7)

Bumps the pub-minor-patch group with 1 update: [supabase_flutter](https://github.com/supabase/supabase-flutter/tree/main/packages).


Updates `supabase_flutter` from 2.18.0 to 2.18.3
- [Release notes](https://github.com/supabase/supabase-flutter/releases)
- [Changelog](https://github.com/supabase/supabase-flutter/blob/supabase_flutter-v2.18.3/CHANGELOG.md)
- [Commits](https://github.com/supabase/supabase-flutter/commits/supabase_flutter-v2.18.3/packages)

---
updated-dependencies:
- dependency-name: supabase_flutter
  dependency-version: 2.18.3
  dependency-type: direct:production
  update-type: version-update:semver-patch
  dependency-group: pub-minor-patch
...

Signed-off-by: dependabot[bot] <support@github.com>
Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com> ([30ce0c8](https://github.com/swaiku/pigeon-finder/commit/30ce0c8a5ddfd056e7b37fafdea337333126c9ca))
- Bump the gradle group in /android with 2 updates (#8)

Bumps the gradle group in /android with 2 updates: [org.jetbrains.kotlin.android](https://github.com/JetBrains/kotlin) and [gradle-wrapper](https://github.com/gradle/gradle).


Updates `org.jetbrains.kotlin.android` from 2.4.20 to 2.4.21
- [Release notes](https://github.com/JetBrains/kotlin/releases)
- [Changelog](https://github.com/JetBrains/kotlin/blob/master/ChangeLog.md)
- [Commits](https://github.com/JetBrains/kotlin/compare/v2.4.20...v2.4.21)

Updates `gradle-wrapper` from 9.8.0 to 9.8.1
- [Release notes](https://github.com/gradle/gradle/releases)
- [Commits](https://github.com/gradle/gradle/compare/v9.8.0...v9.8.1)

---
updated-dependencies:
- dependency-name: org.jetbrains.kotlin.android
  dependency-version: 2.4.21
  dependency-type: direct:production
  update-type: version-update:semver-patch
  dependency-group: gradle
- dependency-name: gradle-wrapper
  dependency-version: 9.8.1
  dependency-type: direct:production
  update-type: version-update:semver-patch
  dependency-group: gradle
...

Signed-off-by: dependabot[bot] <support@github.com>
Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com> ([b12310d](https://github.com/swaiku/pigeon-finder/commit/b12310db99de34608579ec79c46db6de5fefd997))

### 🔀 Other

- Add map translations ([c43cf39](https://github.com/swaiku/pigeon-finder/commit/c43cf39756612a75febe6f9963109471311124b8))
- Merge branch 'develop' into feat/map

# Conflicts:
#	pubspec.lock ([248436f](https://github.com/swaiku/pigeon-finder/commit/248436f93fd95cb55359475d733cf686cf8fac98))
- Tighten analyzer rules and fix unhandled futures ([8602655](https://github.com/swaiku/pigeon-finder/commit/8602655dbb7f4c63ec2302c8f02cb9946ee1ba57))

### 🔧 Configuration

- Regenerate pubspec.lock ([eb7d367](https://github.com/swaiku/pigeon-finder/commit/eb7d367da0bc0617f66ce6916c4182a4dd6eb793))

## v0.0.1 (09-10-2026)

### ♻️ Refactoring

- Add extensions and structure the project with MVVM and Clean Architecture principles ([c204002](https://github.com/swaiku/pigeon-finder/commit/c2040028ef6432c74a19f8e2fab4b8e5215ef469))
- run dart format ([05b5953](https://github.com/swaiku/pigeon-finder/commit/05b59538b19550cc82c4446d77202d0a12473a1c))

### ✅ Tests

- Fix widget test to match the debug home page ([070f76f](https://github.com/swaiku/pigeon-finder/commit/070f76f907ba990a37174a83f6426dbfaa452e17))

### 🎉 Initial

- Initial commit ([f8cfef0](https://github.com/swaiku/pigeon-finder/commit/f8cfef00e6ace21cd27440b580f1ddd0fbf03abe))

### 👷 CI

- Add CI, release workflow, dependabot and pre-commit ([6b93c54](https://github.com/swaiku/pigeon-finder/commit/6b93c544a98fe251237acb1c6eb4a1d859d7048d))
- Bump the actions group across 1 directory with 7 updates

Bumps the actions group with 7 updates in the / directory:

| Package | From | To |
| --- | --- | --- |
| [actions/checkout](https://github.com/actions/checkout) | `6` | `7` |
| [actions/upload-artifact](https://github.com/actions/upload-artifact) | `4` | `6` |
| [actions/setup-java](https://github.com/actions/setup-java) | `4` | `6` |
| [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) | `2` | `3` |
| [actions/dependency-review-action](https://github.com/actions/dependency-review-action) | `4` | `5` |
| [astral-sh/setup-uv](https://github.com/astral-sh/setup-uv) | `5` | `7` |
| [softprops/action-gh-release](https://github.com/softprops/action-gh-release) | `2` | `3` |



Updates `actions/checkout` from 6 to 7
- [Release notes](https://github.com/actions/checkout/releases)
- [Changelog](https://github.com/actions/checkout/blob/main/CHANGELOG.md)
- [Commits](https://github.com/actions/checkout/compare/v6...v7)

Updates `actions/upload-artifact` from 4 to 6
- [Release notes](https://github.com/actions/upload-artifact/releases)
- [Commits](https://github.com/actions/upload-artifact/compare/v4...v6)

Updates `actions/setup-java` from 4 to 6
- [Release notes](https://github.com/actions/setup-java/releases)
- [Commits](https://github.com/actions/setup-java/compare/v4...v6)

Updates `dependabot/fetch-metadata` from 2 to 3
- [Release notes](https://github.com/dependabot/fetch-metadata/releases)
- [Commits](https://github.com/dependabot/fetch-metadata/compare/v2...v3)

Updates `actions/dependency-review-action` from 4 to 5
- [Release notes](https://github.com/actions/dependency-review-action/releases)
- [Commits](https://github.com/actions/dependency-review-action/compare/v4...v5)

Updates `astral-sh/setup-uv` from 5 to 7
- [Release notes](https://github.com/astral-sh/setup-uv/releases)
- [Commits](https://github.com/astral-sh/setup-uv/compare/v5...v7)

Updates `softprops/action-gh-release` from 2 to 3
- [Release notes](https://github.com/softprops/action-gh-release/releases)
- [Changelog](https://github.com/softprops/action-gh-release/blob/master/CHANGELOG.md)
- [Commits](https://github.com/softprops/action-gh-release/compare/v2...v3)

---
updated-dependencies:
- dependency-name: actions/checkout
  dependency-version: '7'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: actions/dependency-review-action
  dependency-version: '5'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: actions/setup-java
  dependency-version: '6'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: actions/upload-artifact
  dependency-version: '6'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: astral-sh/setup-uv
  dependency-version: '7'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: dependabot/fetch-metadata
  dependency-version: '3'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
- dependency-name: softprops/action-gh-release
  dependency-version: '3'
  dependency-type: direct:production
  update-type: version-update:semver-major
  dependency-group: actions
...

Signed-off-by: dependabot[bot] <support@github.com> ([d742ba0](https://github.com/swaiku/pigeon-finder/commit/d742ba0720ce386e4cac597b4187ffa2cf0794bf))
- remove apk build on develop branch ([b72cfb0](https://github.com/swaiku/pigeon-finder/commit/b72cfb0777f57ebdabe40fe80fd2d83dee744f8b))

### 💄 UI & Style

- Add the logo of the app ([201764e](https://github.com/swaiku/pigeon-finder/commit/201764ec0fb31f4aa7175300b3b3de35e890c2cd))
- Add design system theme tokens and base UI components ([3b2d622](https://github.com/swaiku/pigeon-finder/commit/3b2d6222f3021a2cfe040bca98e90f32d366f29a))

### 📝 Documentation

- Add README ([48ed363](https://github.com/swaiku/pigeon-finder/commit/48ed363122420dd04d672e52b2053055531255f5))
- Add CHANGELOG.md ([993236d](https://github.com/swaiku/pigeon-finder/commit/993236d3a52ac1ef3e4dfdfe8e850686f324ccda))

### 📦 Build & Dependencies

- Bump the gradle group in /android with 3 updates (#2)

Bumps the gradle group in /android with 3 updates: com.android.application, [org.jetbrains.kotlin.android](https://github.com/JetBrains/kotlin) and [gradle-wrapper](https://github.com/gradle/gradle).


Updates `com.android.application` from 9.1.0 to 9.4.1

Updates `org.jetbrains.kotlin.android` from 2.4.0 to 2.4.20
- [Release notes](https://github.com/JetBrains/kotlin/releases)
- [Changelog](https://github.com/JetBrains/kotlin/blob/master/ChangeLog.md)
- [Commits](https://github.com/JetBrains/kotlin/compare/v2.4.0...v2.4.20)

Updates `gradle-wrapper` from 9.3.1 to 9.8.0
- [Release notes](https://github.com/gradle/gradle/releases)
- [Commits](https://github.com/gradle/gradle/compare/v9.3.1...v9.8.0)

---
updated-dependencies:
- dependency-name: com.android.application
  dependency-version: 9.4.1
  dependency-type: direct:production
  update-type: version-update:semver-minor
  dependency-group: gradle
- dependency-name: org.jetbrains.kotlin.android
  dependency-version: 2.4.20
  dependency-type: direct:production
  update-type: version-update:semver-patch
  dependency-group: gradle
- dependency-name: gradle-wrapper
  dependency-version: 9.8.0
  dependency-type: direct:production
  update-type: version-update:semver-minor
  dependency-group: gradle
...

Signed-off-by: dependabot[bot] <support@github.com>
Co-authored-by: dependabot[bot] <49699333+dependabot[bot]@users.noreply.github.com> ([99ef445](https://github.com/swaiku/pigeon-finder/commit/99ef445b2de3f59c0d37a524dddbe5f4b7581f55))
- Bump cupertino_icons from 1.0.9 to 2.0.0

Bumps [cupertino_icons](https://github.com/flutter/packages/tree/main/third_party/packages) from 1.0.9 to 2.0.0.
- [Release notes](https://github.com/flutter/packages/releases)
- [Commits](https://github.com/flutter/packages/commits/cupertino_icons-v2.0.0/third_party/packages)

---
updated-dependencies:
- dependency-name: cupertino_icons
  dependency-version: 2.0.0
  dependency-type: direct:production
  update-type: version-update:semver-major
...

Signed-off-by: dependabot[bot] <support@github.com> ([bf464ce](https://github.com/swaiku/pigeon-finder/commit/bf464ce7f2065d52d9d192ce86ced3a74798d7f0))

### 🔀 Other

- remove build report ([689a25e](https://github.com/swaiku/pigeon-finder/commit/689a25ea573efa222266ec7affa93d36e3c05444))
