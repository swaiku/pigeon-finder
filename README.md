<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![CI][ci-shield]][ci-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/swaiku/pigeon-finder">
    <img src="assets/icon/icon.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Pigeon Finder</h3>

  <p align="center">
    Your city is full of pigeons. Prove it.
    <br />
    <a href="https://github.com/swaiku/pigeon-finder"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/swaiku/pigeon-finder/releases">Download</a>
    &middot;
    <a href="https://github.com/swaiku/pigeon-finder/issues/new?labels=bug">Report Bug</a>
    &middot;
    <a href="https://github.com/swaiku/pigeon-finder/issues/new?labels=enhancement">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
        <li><a href="#architecture">Architecture</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li>
      <a href="#contributing">Contributing</a>
      <ul>
        <li><a href="#branches">Branches</a></li>
        <li><a href="#commit-messages">Commit messages</a></li>
        <li><a href="#day-to-day-development">Day-to-day development</a></li>
        <li><a href="#releasing">Releasing</a></li>
        <li><a href="#cicd-overview">CI/CD overview</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Pigeon Finder is a Flutter mobile app where users spot pigeons, photograph them,
pin them on a map and collect them in a personal "Pigeondex". It is built for the
MSE mobile applications course (MA-AdMoApp).

Features:

* **Map**: browse pigeon sightings around you
* **Post**: take a photo and publish a sighting at your location
* **Post detail**: view and like a sighting
* **Pigeondex**: your collection and rankings
* **Profile & auth**: accounts and data powered by Supabase

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* [![Flutter][Flutter]][Flutter-url]
* [![Dart][Dart]][Dart-url]
* [![Supabase][Supabase]][Supabase-url]
* `flutter_bloc` (state management), `go_router` (navigation), `get_it` (dependency injection)
* `flutter_map`, `geolocator`, `camera`
* `flutter_localizations` + `intl` (see `l10n.yaml`)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Architecture

MVVM with Clean Architecture, organized by feature:

```
lib/
├── core/              # shared code: config, di, error, router, theme, widgets
├── features/
│   └── <feature>/     # auth, map, post, post_detail, pigeondex, profile
│       ├── data/          # data sources, models, repository implementations
│       ├── domain/        # entities, repository contracts, use cases
│       └── presentation/  # bloc, pages, widgets
└── l10n/              # translations
```

Dependencies point inward: `presentation` → `domain` ← `data`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running, follow these steps.

### Prerequisites

* [Flutter](https://docs.flutter.dev/get-started/install) (stable channel)
* A [Supabase](https://supabase.com) project (URL + anon key)
* Optional dev tooling:
  [`pre-commit`](https://pre-commit.com),
  [`bump-my-version`](https://callowayproject.github.io/bump-my-version/) and
  [`git-cliff`](https://git-cliff.org)

### Installation

1. Clone the repo
   ```sh
   git clone git@github.com:swaiku/pigeon-finder.git
   cd pigeon-finder
   ```
2. Install dependencies
   ```sh
   flutter pub get
   ```
3. Install the git hooks (optional)
   ```sh
   pre-commit install
   ```
   * On commit: whitespace/YAML/TOML checks, `dart format`, and a check that the
     commit message starts with a gitmoji.
   * On push: `flutter analyze` and `flutter test`.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- USAGE EXAMPLES -->
## Usage

Supabase credentials are injected at build time and never committed:

```sh
flutter run \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Checks:

```sh
dart format lib test
flutter analyze
flutter test
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

### Branches

| Branch               | Purpose                                              |
| -------------------- | ---------------------------------------------------- |
| `main`               | Released code only. Every merge publishes a release. |
| `develop`            | Integration branch. All work lands here first.      |
| `feat/*`, `fix/*`, … | Short-lived branches created from `develop`.         |

`main` and `develop` should be protected: changes go through pull requests with
a green CI.

### Commit messages

Commits start with a [gitmoji](https://gitmoji.dev) (emoji or `:code:`), followed
by a short imperative description. The changelog is grouped by this emoji.

| Gitmoji                                            | Changelog group        |
| -------------------------------------------------- | ---------------------- |
| ✨ `:sparkles:`, ⚡ `:zap:`                         | Features               |
| 💄 `:lipstick:`                                    | UI & Style             |
| 🐛 `:bug:`, 🚑 `:ambulance:`                        | Bug Fixes              |
| ♻️ `:recycle:`, 🎨 `:art:`                          | Refactoring            |
| ⬆️ `:arrow_up:`, ⬇️ `:arrow_down:`, 📦 `:package:`  | Build & Dependencies   |
| 👷 `:construction_worker:`                         | CI                     |
| 📝 `:memo:`                                        | Documentation          |
| 🔧 `:wrench:`, 🔨 `:hammer:`                        | Configuration          |
| ✅ `:white_check_mark:`, 🧪 `:test_tube:`           | Tests                  |

Example: `✨ Add like button on post detail`.

### Day-to-day development

1. Create your feature branch from `develop`
   ```sh
   git switch develop && git pull
   git switch -c feat/like-button
   ```
2. Commit your changes with a gitmoji message
3. Push the branch
   ```sh
   git push -u origin feat/like-button
   ```
4. Open a pull request targeting `develop`

CI (format, analyze, tests, debug APK build) runs on every PR and on pushes to
`main` and `develop`. Dependabot opens weekly dependency PRs against `develop`
(minor/patch updates are auto-merged once CI is green).

### Releasing

1. On an up-to-date `develop`, bump the version:
   ```sh
   bump-my-version bump patch   # or minor / major
   ```
   This updates `version:` in `pubspec.yaml`, regenerates `CHANGELOG.md` with
   git-cliff and creates a `🔖 Bump version …` commit.
2. Push `develop` and open a pull request **`develop` → `main`**. Merge it with
   a **merge commit** (not squash) so the individual gitmoji commits are kept.
3. The merge triggers the `Release` workflow: if the version in `pubspec.yaml`
   has no tag yet, it builds the release APK, creates the `vX.Y.Z` tag and
   publishes a GitHub Release with the generated notes and the APK attached.

Required repository secrets: `SUPABASE_URL` and `SUPABASE_ANON_KEY`.

> The release APK is currently signed with the debug key. Configure a proper
> signing config before publishing to a store.

### CI/CD overview

| Workflow                   | Trigger                      | What it does                         |
| -------------------------- | ---------------------------- | ------------------------------------ |
| `ci.yml`                   | PR, push to `main`/`develop` | format, analyze, test, debug APK     |
| `release.yml`              | push to `main`               | tag + build + GitHub Release         |
| `dependency-review.yml`    | PR                           | blocks high-severity vulnerable deps |
| `dependabot-automerge.yml` | Dependabot PRs               | auto-merge non-major updates         |

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

No license has been chosen yet.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Jérémy Prin - [@swaiku](https://github.com/swaiku)

Project Link: [https://github.com/swaiku/pigeon-finder](https://github.com/swaiku/pigeon-finder)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
* [Gitmoji](https://gitmoji.dev)
* [git-cliff](https://git-cliff.org)
* [bump-my-version](https://callowayproject.github.io/bump-my-version/)
* [Img Shields](https://shields.io)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/swaiku/pigeon-finder.svg?style=for-the-badge
[contributors-url]: https://github.com/swaiku/pigeon-finder/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/swaiku/pigeon-finder.svg?style=for-the-badge
[forks-url]: https://github.com/swaiku/pigeon-finder/network/members
[stars-shield]: https://img.shields.io/github/stars/swaiku/pigeon-finder.svg?style=for-the-badge
[stars-url]: https://github.com/swaiku/pigeon-finder/stargazers
[issues-shield]: https://img.shields.io/github/issues/swaiku/pigeon-finder.svg?style=for-the-badge
[issues-url]: https://github.com/swaiku/pigeon-finder/issues
[ci-shield]: https://img.shields.io/github/actions/workflow/status/swaiku/pigeon-finder/ci.yml?branch=main&style=for-the-badge&label=CI
[ci-url]: https://github.com/swaiku/pigeon-finder/actions/workflows/ci.yml
[Flutter]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev/
[Dart]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev/
[Supabase]: https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white
[Supabase-url]: https://supabase.com/
