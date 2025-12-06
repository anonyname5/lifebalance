# LifeBalance

**Your daily companion for better health habits and financial wellness**

A Flutter mobile application that helps users build better eating habits, stay hydrated, and manage their finances effectively through simple daily tracking and insights.

## Features

### Wellness Tracking
- 💧 Water intake tracking with daily goals (customizable)
- 🍽️ Meal logging with timestamps and notes
- 📊 Wellness insights and trends
- 🔥 Streak tracking for water intake and meal logging
- 📈 Daily, weekly, and monthly wellness scores with letter grades
- 🏆 Achievement system with 13 unlockable achievements

### Finance Management
- 💰 Expense tracking by category (8 predefined categories)
- 📈 Budget management and monitoring with real-time progress
- 🎯 Savings goals tracking with progress visualization
- 📊 Financial insights and reports (spending trends, category breakdown)
- 🔔 Budget alert notifications (80% and 100% thresholds)
- 🔄 Recurring expenses with automatic logging
- 📤 Data export (CSV and PDF formats)

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod 2.4.9
- **Database**: SQLite (sqflite 2.3.0)
- **UI**: Material Design 3
- **Charts**: fl_chart 0.65.0
- **Notifications**: flutter_local_notifications 17.2.1
- **Export**: CSV and PDF generation

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget
├── core/                     # Core utilities and constants
│   ├── constants/           # App colors, strings, theme
│   ├── utils/               # Helper functions
│   └── widgets/             # Reusable widgets
├── data/                     # Data layer
│   ├── database/            # Database setup and helpers
│   ├── models/              # Data models
│   └── repositories/        # Data repositories
├── features/                 # Feature modules
│   ├── home/                # Dashboard
│   ├── wellness/            # Water & meal tracking
│   ├── finance/             # Expenses & budgets
│   ├── insights/            # Analytics & reports
│   └── settings/            # App settings
└── services/                 # App services
    ├── notification_service.dart
    ├── export_service.dart
    ├── preferences_service.dart
    ├── recurring_expense_service.dart
    ├── data_cleanup_service.dart
    ├── budget_alert_service.dart
    ├── streak_service.dart
    ├── wellness_score_service.dart
    ├── achievement_service.dart
    └── analytics_service.dart
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- Android SDK / Xcode

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd lifebalance
```

2. Install dependencies
```bash
flutter pub get
```

3. Run code generation (for Riverpod providers)
```bash
flutter pub run build_runner build
```

4. Run the app
```bash
flutter run
```

## Development Phases

### Phase 1: MVP (2-3 weeks) ✅ **COMPLETE**
- ✅ Project setup
- ✅ Basic navigation
- ✅ Water tracking
- ✅ Meal logging
- ✅ Expense tracking
- ✅ Budget management
- ✅ Dashboard with real-time data
- ✅ Insights with charts
- ✅ Settings screen

### Phase 2: Enhanced Features (2-3 weeks) ✅ **COMPLETE**
- ✅ Advanced insights with charts and analytics
- ✅ Smart notifications (water, meal, and budget alerts)
- ✅ Goals & gamification (achievement system with 13 achievements)
- ✅ Savings goals tracking
- ✅ Recurring expenses with auto-logging
- ✅ Streak tracking (water and meal streaks)
- ✅ Wellness scores (daily, weekly, monthly with grades)
- ✅ User profile management
- ✅ Data export (CSV/PDF)
- ✅ Budget alert notifications

### Phase 3: Advanced Features (2 weeks) ✅ **COMPLETE**
- ✅ Dark mode (Light, Dark, System themes)
- ✅ Multi-currency support (USD & MYR)
- ✅ Advanced filtering and search (expenses, meals, water logs)
- ✅ Custom categories and icons (25+ icons, custom colors)
- ✅ Receipt photo attachment (gallery & camera)

**See [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) for detailed status.**

## Current Status

**Version:** 1.0.0  
**Status:** Phase 1, Phase 2 & Phase 3 Complete ✅

The app is fully functional with all MVP features, enhanced features, and advanced features implemented. **Ready for GitHub release and production use!** 🚀

### Key Statistics
- **17+ screens** implemented
- **18+ Riverpod providers** for state management
- **7 repositories** for data access
- **9 services** for app functionality
- **8 data models** with full CRUD operations
- **13 achievements** across 6 categories

## App Icon

✅ **App icon is configured!** The app uses a custom icon generated from `assets/icon/app_icon.png`.

Icons have been generated for:
- ✅ Android (all screen densities)
- ✅ iOS (if configured)
- ✅ Web favicon

To regenerate icons after updating the icon file:
```bash
flutter pub run flutter_launcher_icons
```

## License

This project is private and not published to pub.dev.

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)
