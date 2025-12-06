# App Icon Setup Guide

## Quick Start

1. **Prepare your icon:**
   - Create a PNG image (1024x1024 pixels recommended)
   - Name it `app_icon.png`
   - Place it in this `assets/icon/` folder

2. **Optional - Android Adaptive Icon:**
   - Create a foreground icon (1024x1024 PNG)
   - Name it `app_icon_foreground.png`
   - Place it in this `assets/icon/` folder
   - The background will be #6366F1 (Primary Indigo)

3. **Generate icons:**
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Done!** The icons will be automatically generated for:
   - Android (all screen densities)
   - iOS (if configured)

## Current Configuration

- **Background Color:** #6366F1 (Primary Indigo)
- **Main Icon:** `assets/icon/app_icon.png`
- **Foreground Icon:** `assets/icon/app_icon_foreground.png` (optional)

## Icon Design Tips

For LifeBalance app, consider these themes:
- 💧 Water drop (wellness focus)
- ⚖️ Balance scale (life balance)
- 💚 Heart/health icon
- 📊 Analytics/chart icon
- 🌱 Growth/wellness icon
- 🎯 Target/goal icon

**Requirements:**
- ✅ PNG format with transparent background
- ✅ Minimum 1024x1024 pixels
- ✅ Good contrast for visibility
- ✅ Works at small sizes (test at 48x48)
- ✅ Simple, recognizable design

## Online Icon Generators

You can use these tools to create your icon:
- [AppIcon.co](https://www.appicon.co/)
- [IconKitchen](https://icon.kitchen/)
- [Canva](https://www.canva.com/) - Search "app icon"
- [Figma](https://www.figma.com/) - Design your own

## Troubleshooting

If icons don't update:
1. Run `flutter clean`
2. Delete `android/app/src/main/res/mipmap-*/ic_launcher.png` files
3. Run `flutter pub run flutter_launcher_icons` again
4. Rebuild the app
