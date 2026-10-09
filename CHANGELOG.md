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
