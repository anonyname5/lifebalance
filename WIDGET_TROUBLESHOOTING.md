# Widget Troubleshooting Guide

## Issue: "Can't load widget" Error

If you're seeing "Can't load widget" when trying to add the widget to your home screen, follow these steps:

### Step 1: Rebuild the App
1. Open terminal in your project directory
2. Run: `flutter clean`
3. Run: `flutter pub get`
4. Rebuild and install the app on your device

### Step 2: Verify Widget is Registered
The widget should be registered in `AndroidManifest.xml`. Check that you have:
```xml
<receiver
    android:name=".LifeBalanceWidgetProvider"
    android:exported="true">
    <intent-filter>
        <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
    </intent-filter>
    <meta-data
        android:name="android.appwidget.provider"
        android:resource="@xml/widget_info" />
</receiver>
```

### Step 3: Check Build Output
1. Build the app: `flutter build apk` or `flutter run`
2. Check for any errors related to:
   - `R.layout.widget_layout` not found
   - `R.id.widget_*` not found
   - Kotlin compilation errors

### Step 4: Verify Files Exist
Make sure these files exist:
- `android/app/src/main/kotlin/com/lifebalance/lifebalance/LifeBalanceWidgetProvider.kt`
- `android/app/src/main/res/layout/widget_layout.xml`
- `android/app/src/main/res/xml/widget_info.xml`
- `android/app/src/main/res/values/strings.xml`

### Step 5: Check Logcat
1. Connect your device
2. Run: `adb logcat | grep -i "lifebalance\|widget"`
3. Look for errors when trying to add the widget

### Step 6: Test Widget Manually
1. Open the app first
2. Let it initialize (this creates the SharedPreferences)
3. Then try adding the widget

### Step 7: Uninstall and Reinstall
Sometimes Android caches widget information:
1. Uninstall the app completely
2. Reinstall fresh
3. Open app once
4. Try adding widget again

### Common Issues and Fixes

#### Issue: R.layout.widget_layout not found
**Fix**: Make sure `widget_layout.xml` is in `android/app/src/main/res/layout/`

#### Issue: Widget crashes on load
**Fix**: The widget provider now has better error handling. Check logcat for specific errors.

#### Issue: Widget shows "0" for everything
**Fix**: This is normal if you haven't added any data yet. Open the app and add some data, then the widget will update.

#### Issue: Widget doesn't update
**Fix**: 
1. Make sure `WidgetService.updateWidget()` is being called
2. Check that data is being saved to SharedPreferences
3. Verify the MethodChannel is working

### Testing the Widget

1. **First Time Setup**:
   - Install the app
   - Open the app (this initializes SharedPreferences)
   - Add some data (water, expense, meal)
   - Go to home screen
   - Long press → Widgets → Find "LifeBalance"
   - Add widget

2. **Verify Widget Updates**:
   - Add water in the app
   - Widget should update automatically
   - If not, wait 30 minutes for periodic update

### Still Having Issues?

If the widget still doesn't load:
1. Check Android version (widget requires Android 4.0+)
2. Verify app has necessary permissions
3. Try on a different device/emulator
4. Check if other widgets work on your device
5. Review logcat output for specific error messages

### Debug Mode

To see widget update logs:
```bash
adb logcat | grep LifeBalanceWidget
```

This will show:
- When widget tries to update
- Any errors during update
- Data being read from SharedPreferences
