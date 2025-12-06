@echo off
echo ========================================
echo LifeBalance - Push to GitHub
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Checking git status...
git status
echo.

echo [2/4] Adding all files...
git add .
echo.

echo [3/4] Creating commit...
git commit -m "Initial commit: LifeBalance v1.0.0 - Complete app with all features"
echo.

echo [4/4] Pushing to GitHub...
echo.
echo NOTE: You may be prompted for GitHub credentials.
echo If you see authentication errors, you may need to:
echo - Use a Personal Access Token (Settings ^> Developer settings ^> Personal access tokens)
echo - Or use GitHub CLI: gh auth login
echo.
git push -u origin main
echo.

echo ========================================
echo Push completed! Check your repository:
echo https://github.com/anonyname5/lifebalance-
echo ========================================
pause
