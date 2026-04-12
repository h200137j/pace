<div align="center">

<br />

```
██████╗  █████╗  ██████╗███████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝███████║██║     █████╗  
██╔═══╝ ██╔══██║██║     ██╔══╝  
██║     ██║  ██║╚██████╗███████╗
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚══════╝
```

**Build streaks. Break limits. Set the pace.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Isar](https://img.shields.io/badge/Isar-Database-6750A4?style=for-the-badge)](https://isar.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-State-00BCD4?style=for-the-badge)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br />

</div>

---

## What is Pace?

**Pace** is a beautifully crafted, offline-first habit and activity tracker built with Flutter. It's designed around one idea: *making it frictionless to show up every single day*.

Whether you're building a 30-day coding challenge, tracking a daily meditation practice, or logging focused deep-work sessions — Pace gives you the visual feedback and streak motivation to keep going.

No subscriptions. No cloud sync. No noise. Just you and your habits, stored privately on your device.

---

## ✨ Features

### 🎯 Three Activity Types
Create and track in three different modes depending on your goal:

| Type | Best For |
|---|---|
| **Challenge** | Time-boxed streaks — "30 days of running" |
| **Task** | Recurring daily habits — "Drink 2L of water" |
| **Focus** | Deep-work logging — "2 hours of coding" |

Each activity gets its own **color**, **icon**, and **target day schedule** (e.g. weekdays only).

---

### 📅 Frictionless Daily Check-In
Your home dashboard shows everything due today. A single tap on the animated progress ring marks a habit as **done** — no menus, no extra steps.

- Live **streak badge** 🔥 updates instantly
- **Week dot indicator** shows your last 7 days at a glance
- **Gradient cards** pulse with your chosen activity color

---

### 🔥 Streaks That Keep You Honest
Pace calculates your streaks in real-time, with zero approximation:

- **Current streak** — consecutive days done up to today
- **Longest streak** — your personal record, tracked forever
- **Completion rate** — percentage since you created the habit
- **Total completions** — raw count of every day you showed up

---

### 🗓️ GitHub-Style Contribution Grid
Every activity gets a **52-week heatmap** — just like GitHub's contribution graph. See your consistency across the entire year at one glance. Tap any cell for a day-specific tooltip.

```
Jan   Feb   Mar   Apr   May  ...
M  ░░░▒▒▒███░░░▒▒▒░░░███▒▒▒░░░
T  ▒▒▒░░░▒▒▒███░░░███▒▒▒░░░███
W  ███▒▒▒░░░░░░███░░░░░░███▒▒▒
```

---

### 📊 Rich Analytics (fl_chart)
Navigate to Analytics for beautiful, interactive charts:

- **Week View** — grouped bar chart comparing all activities over the last 7 days, plus individual progress bars per habit
- **Month View** — curved multi-line area chart tracking 30 days of activity patterns
- **Year View** — activity-selector + heatmap + monthly bar chart for the full calendar year

---

### 📤 Data Portability
Your data is yours. Always.

- **Export JSON** — full backup of all activities and completion records
- **Import JSON** — restore from any previous backup
- **Export CSV** — open your history in Excel, Google Sheets, or any tool you like

---

### 🎨 Material 3 Design
Pace is built on top of Flutter's latest Material 3 design system:

- Dynamic **seed-color theming** — pick any accent color and the entire UI adapts
- First-class **dark mode** support
- **Outfit** typography for a clean, modern reading experience
- Smooth micro-animations on every interaction
- FlexColorScheme surface blending for a polished, cohesive look

---

## 🏗️ Architecture

Pace follows a strict separation of concerns across three layers:

```
📦 pace/lib/
│
├── 🎨 core/                   # Framework-agnostic utilities
│   ├── constants/             # Color palette, icon registry
│   ├── theme/                 # M3 ThemeData via FlexColorScheme
│   └── utils/                 # Date helpers, streak calculator
│
├── 🗄️ data/                   # Data layer — no Flutter widgets here
│   ├── models/                # Isar @Collection schemas
│   │   ├── activity.dart      # Challenge / Task / Focus
│   │   └── completion.dart    # Per-day check-in record
│   ├── repositories/          # Isar queries + write transactions
│   └── services/              # IsarService singleton, ExportService
│
├── ⚡ providers/               # Riverpod state management
│   ├── activity_provider.dart
│   ├── completion_provider.dart
│   ├── analytics_provider.dart
│   └── theme_provider.dart
│
└── 🖼️ ui/
    ├── widgets/               # Reusable components
    │   ├── activity_card.dart       # Gradient card + check-in ring
    │   ├── contribution_grid.dart   # 52-week heatmap
    │   ├── streak_badge.dart        # 🔥 pill badge
    │   ├── progress_ring.dart       # Custom painted ring
    │   └── empty_state.dart
    └── screens/
        ├── home/              # Daily dashboard
        ├── detail/            # Per-activity stats + charts
        ├── create/            # Create / edit bottom sheet
        ├── analytics/         # Week / Month / Year tabs
        └── settings/          # Theme, export, import
```

---

## 🧰 Tech Stack

| Package | Purpose |
|---|---|
| [`isar`](https://pub.dev/packages/isar) | Blazing-fast embedded NoSQL database |
| [`flutter_riverpod`](https://pub.dev/packages/flutter_riverpod) | Reactive state management |
| [`go_router`](https://pub.dev/packages/go_router) | Declarative navigation with nested shells |
| [`fl_chart`](https://pub.dev/packages/fl_chart) | Interactive bar, line & area charts |
| [`flex_color_scheme`](https://pub.dev/packages/flex_color_scheme) | M3 ColorScheme generation from seed |
| [`google_fonts`](https://pub.dev/packages/google_fonts) | Outfit typography |
| [`share_plus`](https://pub.dev/packages/share_plus) | Cross-platform share sheet for exports |
| [`file_picker`](https://pub.dev/packages/file_picker) | JSON import file picker |
| [`csv`](https://pub.dev/packages/csv) | CSV encode / decode |
| [`intl`](https://pub.dev/packages/intl) | Date formatting |
| [`path_provider`](https://pub.dev/packages/path_provider) | Documents directory access |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Dart `>=3.0.0`

### Installation

```bash
# Clone the repository
git clone https://github.com/h200137j/pace.git
cd pace

# Install dependencies
flutter pub get

# Generate Isar schemas (required on first run)
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

> **Note:** The Isar code generator (`build_runner`) must be run at least once to generate the `activity.g.dart` and `completion.g.dart` schema files. These are excluded from version control.

---

## 📁 File Structure Summary

```
pace/
├── lib/
│   ├── main.dart              # App entry + Isar init
│   ├── app.dart               # MaterialApp.router + theme wiring
│   ├── router.dart            # go_router config + bottom nav shell
│   ├── core/
│   ├── data/
│   ├── providers/
│   └── ui/
├── pubspec.yaml
└── README.md
```

---

## 🔒 Privacy

Pace stores all data **100% locally** on your device using Isar. No analytics, no tracking, no network requests — ever. Your habits are nobody's business but yours.

---

## 🛣️ Roadmap

- [ ] Local push notification reminders
- [ ] Android / iOS home screen widget
- [ ] Multiple streaks per activity (e.g. weekly targets)
- [ ] Notes per completion entry
- [ ] iCloud / Google Drive optional sync
- [ ] Apple Watch / Wear OS companion

---

## 🤝 Contributing

Pull requests are welcome! Please open an issue first to discuss any significant changes.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit using Conventional Commits: `git commit -m "feat: add reminder notifications"`
4. Push: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ and Flutter

*Keep your pace. Every day counts.*

</div>
