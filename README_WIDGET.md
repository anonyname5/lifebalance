# Home Screen Widget Implementation

This document describes the home screen widget feature for LifeBalance app.

## Overview

The home screen widget allows users to view their daily wellness and finance stats directly on their device's home screen without opening the app.

## Android Widget

### Features
- **Water Intake**: Shows current glasses consumed vs goal with progress bar
- **Today's Spending**: Displays today's total expenses
- **Meal Count**: Shows number of meals logged today
- **Monthly Spending**: Displays current month's total spending

### Implementation Details

#### Files Created:
1. `android/app/src/main/kotlin/com/lifebalance/lifebalance/LifeBalanceWidgetProvider.kt`
   - Widget provider that handles widget updates
   - Reads data from SharedPreferences
   - Updates widget UI

2. `android/app/src/main/res/layout/widget_layout.xml`
   - Widget layout with all UI elements
   - Responsive design for different widget sizes

3. `android/app/src/main/res/xml/widget_info.xml`
   - Widget configuration
   - Defines minimum size and update frequency

4. `lib/services/widget_service.dart`
   - Flutter service to update widget data
   - Fetches data from repositories
   - Saves to SharedPreferences
   - Communicates with native code via MethodChannel

#### How It Works:
1. When data changes (water added, expense added, etc.), `WidgetService.updateWidget()` is called
2. Service fetches current data from repositories
3. Data is saved to SharedPreferences (accessible by native code)
4. MethodChannel notifies Android widget provider
5. Widget provider reads data and updates UI

#### Auto-Update Points:
- When water is added/deleted
- When meal is added/deleted
- When expense is added/deleted
- On app startup

### Adding the Widget

1. Long press on home screen
2. Select "Widgets"
3. Find "LifeBalance"
4. Drag to desired location
5. Widget will automatically update every 30 minutes (or when data changes)

## iOS Widget (Future Implementation)

iOS WidgetKit extension can be added for iOS 14+ support. This would require:
- Creating a WidgetKit extension target
- Using SwiftUI for widget UI
- App Groups for data sharing between app and widget
- Timeline provider for scheduled updates

## Technical Notes

- Widget updates automatically when data changes in the app
- Widget also updates every 30 minutes via Android's updatePeriodMillis
- Data is stored in SharedPreferences with "flutter." prefix (Flutter convention)
- Widget gracefully handles missing data by showing default values

## Troubleshooting

If widget doesn't update:
1. Check that widget is properly added to home screen
2. Verify app has necessary permissions
3. Try removing and re-adding the widget
4. Check logs for any errors in widget provider
