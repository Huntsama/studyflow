# 🚀 Deploy StudyFlow to GitHub for Automatic Builds

## Quick Setup (2 minutes):

### Step 1: Create GitHub Repository
1. Go to https://github.com/new
2. Repository name: `studyflow`
3. Description: `StudyFlow - Modern Student Task Manager`
4. Public or Private (your choice)
5. Click "Create repository"

### Step 2: Push Code to GitHub
```bash
# In your terminal, from this project folder:
git remote add origin https://github.com/YOUR_USERNAME/studyflow.git
git branch -M main
git push -u origin main --tags
```

### Step 3: Magic Happens! 🎉
- GitHub automatically builds your app on Windows, macOS, Linux, and Android
- Go to your repo → Actions tab to watch the builds
- When complete, go to Releases tab to download:
  - **StudyFlow-Windows-v1.0.0.zip** (contains studyflow.exe)
  - **StudyFlow-macOS-v1.0.0.zip** (contains StudyFlow.app)
  - **StudyFlow-Linux-v1.0.0.tar.gz** (Linux executable)
  - **StudyFlow-Android-v1.0.0.apk** (Android app)

## What Gets Built:

✅ **Windows .exe** - Real executable for Windows
✅ **macOS .app** - Real Mac application
✅ **Linux executable** - Ready to run on Linux
✅ **Android .apk** - Installable Android app

## Send to Friends:

- **Windows friends**: Send them the .zip, they extract and run studyflow.exe
- **Mac friends**: Send them the .zip, they extract and drag StudyFlow.app to Applications
- **Linux friends**: Send them the .tar.gz, they extract and run ./studyflow
- **Android friends**: Send them the .apk, they install it

No building, no setup, just download and run!

---

**Built with GitHub Actions** - Free automatic builds for all platforms! 🌟