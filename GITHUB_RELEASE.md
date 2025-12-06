# GitHub Release Guide

## Pre-Release Checklist ✅

- [x] All features implemented (Phase 1, 2, 3 complete)
- [x] App icon configured and generated
- [x] Documentation updated (README.md, DEVELOPMENT_STATUS.md)
- [x] Code compiles without errors
- [x] .gitignore configured
- [x] Web metadata updated

## Step-by-Step Release Instructions

### 1. Initialize Git Repository (if not already done)

```bash
cd "c:\Users\User\Downloads\Mini Project\New"
git init
```

### 2. Add All Files

```bash
git add .
```

### 3. Create Initial Commit

```bash
git commit -m "Initial commit: LifeBalance v1.0.0

- Complete Flutter app with all Phase 1, 2, and 3 features
- Wellness tracking (water, meals, streaks, achievements)
- Finance management (expenses, budgets, savings, recurring)
- Advanced features (dark mode, multi-currency, filtering, receipt photos)
- Custom app icon configured
- Full documentation included"
```

### 4. Create GitHub Repository

1. Go to [GitHub.com](https://github.com)
2. Click the "+" icon in the top right
3. Select "New repository"
4. Repository name: `lifebalance` (or your preferred name)
5. Description: "Your daily companion for better health habits and financial wellness"
6. Choose Public or Private
7. **DO NOT** initialize with README, .gitignore, or license (we already have these)
8. Click "Create repository"

### 5. Connect Local Repository to GitHub

After creating the repository on GitHub, you'll see instructions. Use these commands:

```bash
# Add remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/lifebalance.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

### 6. Create Release Tag

```bash
# Create annotated tag
git tag -a v1.0.0 -m "LifeBalance v1.0.0 - Complete Release

Features:
- Wellness tracking with streaks and achievements
- Finance management with budgets and savings goals
- Dark mode and multi-currency support
- Advanced filtering and search
- Receipt photo attachment
- Custom categories and icons"

# Push tag to GitHub
git push origin v1.0.0
```

### 7. Create GitHub Release (Optional but Recommended)

1. Go to your repository on GitHub
2. Click "Releases" on the right sidebar
3. Click "Create a new release"
4. Choose tag: `v1.0.0`
5. Release title: `LifeBalance v1.0.0 - Complete Release`
6. Description:
   ```
   # LifeBalance v1.0.0 🎉
   
   Complete release with all features from Phase 1, 2, and 3.
   
   ## ✨ Features
   
   ### Wellness Tracking
   - Water intake tracking with daily goals
   - Meal logging with timestamps
   - Streak tracking
   - Wellness scores (daily, weekly, monthly)
   - Achievement system (13 achievements)
   
   ### Finance Management
   - Expense tracking by category
   - Budget management with real-time progress
   - Savings goals tracking
   - Recurring expenses
   - Financial insights and reports
   - Data export (CSV/PDF)
   
   ### Advanced Features
   - Dark mode (Light/Dark/System)
   - Multi-currency support (USD/MYR)
   - Advanced filtering and search
   - Custom categories and icons
   - Receipt photo attachment
   
   ## 📦 Installation
   
   See README.md for installation instructions.
   
   ## 📚 Documentation
   
   - [README.md](README.md) - Project overview and setup
   - [DEVELOPMENT_STATUS.md](DEVELOPMENT_STATUS.md) - Detailed development status
   ```
7. Click "Publish release"

## Quick Command Summary

```bash
# Initialize and commit
git init
git add .
git commit -m "Initial commit: LifeBalance v1.0.0"

# Connect to GitHub (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/lifebalance.git
git branch -M main
git push -u origin main

# Create and push tag
git tag -a v1.0.0 -m "LifeBalance v1.0.0 - Complete Release"
git push origin v1.0.0
```

## Post-Release

After releasing, you can:
- Add screenshots to README.md
- Create a CONTRIBUTING.md (if open source)
- Set up GitHub Actions for CI/CD (optional)
- Add issue templates (optional)

## Troubleshooting

### If you get authentication errors:
- Use GitHub CLI: `gh auth login`
- Or use Personal Access Token instead of password
- Or use SSH: `git remote set-url origin git@github.com:YOUR_USERNAME/lifebalance.git`

### If files are too large:
- Check .gitignore is working
- Remove large files: `git rm --cached <file>`
- Add to .gitignore and commit again

---

**Ready to release!** 🚀
