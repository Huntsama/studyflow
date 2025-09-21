# StudyFlow 🎓

A modern student task manager for organizing courses, assignments, and study sessions. Built with Flutter for cross-platform compatibility.

![StudyFlow](https://img.shields.io/badge/Platform-Linux%20%7C%20Windows%20%7C%20macOS%20%7C%20Android%20%7C%20iOS-blue)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B.svg?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## ✨ Features

- 📚 **Course Management**: Track multiple courses with progress indicators
- 📝 **Assignment Tracking**: Set priorities and deadlines for all tasks
- 🎯 **Project Management**: Break down big projects into manageable milestones
- 📖 **Lecture Organization**: 3-phase study system (Read → Practice → Finalize)
- 💾 **Data Export/Import**: Backup and restore all your data
- 🌙 **Dark Theme Support**: Fully adaptive UI for day/night use
- 🔒 **Persistent Storage**: Never lose your data between sessions
- 📱 **Cross-Platform**: Works on Linux, Windows, macOS, Android, and iOS

## 🚀 Quick Install for Linux

### One-Click Installation Script

Download and run our automated installation script:

```bash
# Download the installation script
curl -o install_studyflow.sh https://raw.githubusercontent.com/your-repo/studyflow/main/scripts/install_studyflow.sh

# Make it executable and run
chmod +x install_studyflow.sh
./install_studyflow.sh
```

**What it does:**
- ✅ Installs Flutter SDK automatically
- ✅ Installs all required Linux dependencies
- ✅ Builds StudyFlow for your system
- ✅ Creates desktop shortcut
- ✅ Adds command-line access

**After installation:**
- 🖱️ **Desktop**: Find "StudyFlow" in your applications menu
- ⌨️ **Terminal**: Type `studyflow`
- 📁 **Direct**: Run `~/.local/studyflow/studyflow`

### Manual Installation

If you prefer to install manually:

#### Prerequisites

1. **Install Flutter SDK:**
   ```bash
   # Option 1: Using Snap (Recommended)
   sudo snap install flutter --classic

   # Option 2: Manual download
   # Download from https://flutter.dev/docs/get-started/install/linux
   ```

2. **Install Linux Dependencies:**
   ```bash
   sudo apt-get update
   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libblkid-dev
   ```

3. **Enable Linux Desktop Support:**
   ```bash
   flutter config --enable-linux-desktop
   ```

#### Build and Install

```bash
# Clone the repository
git clone https://github.com/your-repo/studyflow.git
cd studyflow

# Install dependencies
flutter pub get

# Build for Linux
flutter build linux --release

# Install to system
mkdir -p ~/.local/studyflow
cp -r build/linux/x64/release/bundle/* ~/.local/studyflow/
chmod +x ~/.local/studyflow/studyflow

# Create desktop entry
cat > ~/.local/share/applications/studyflow.desktop << EOF
[Desktop Entry]
Name=StudyFlow
Comment=Modern student task manager
Exec=$HOME/.local/studyflow/studyflow
Icon=applications-education
Terminal=false
Type=Application
Categories=Education;Office;
EOF

# Update desktop database
update-desktop-database ~/.local/share/applications/
```

## 🖥️ Platform Support

### Linux Desktop
- **Ubuntu/Debian**: Fully supported
- **Fedora/CentOS**: Supported with dnf package manager
- **Arch Linux**: Supported with pacman
- **Other Distributions**: Should work with appropriate package managers

### Other Platforms
- **Windows**: `flutter build windows`
- **macOS**: `flutter build macos`
- **Android**: `flutter build apk`
- **iOS**: `flutter build ios`
- **Web**: `flutter build web`

## 📖 Getting Started

### Adding Your First Course

1. **Launch StudyFlow** from your applications menu
2. **Click the "+" button** or "Add Your First Course"
3. **Fill in course details:**
   - Course name (e.g., "Data Structures")
   - Description
   - Semester/Term
   - Credits
   - Choose a color theme
4. **Click "Add Course"**

### Managing Assignments

1. **Open a course** from the dashboard
2. **Navigate to "Assignments" tab**
3. **Add assignments** with:
   - Title and description
   - Due date
   - Priority level (Low/Medium/High)
4. **Track progress** by marking as complete

### Organizing Lectures

StudyFlow uses a 3-phase learning system:

1. **📖 To-do/Read**: Initial learning phase
2. **🧠 Understood & Practiced**: Comprehension and practice
3. **✅ Finalized**: Mastery and review complete

### Project Management

1. **Create projects** within courses
2. **Break down into milestones**
3. **Set deadlines** for each milestone
4. **Track overall progress**

### Data Management

#### Export Your Data
1. Go to **Settings → Data Management**
2. Click **"Export Data"**
3. Choose save location
4. File includes all courses, assignments, projects, and preferences

#### Import Data
1. Go to **Settings → Data Management**
2. Click **"Import Data"**
3. Select your backup file
4. Confirm restoration (replaces current data)

### Customization

#### Dark Theme
- **Settings → Display Preferences → Dark Mode**
- All UI elements automatically adapt

#### Text Size
- **Settings → Accessibility → Text Size**
- Adjust from 80% to 150% scaling

#### High Contrast
- **Settings → Accessibility → High Contrast**
- Enhanced visibility for better readability

## 🛠️ Development

### Setting up Development Environment

```bash
# Clone repository
git clone https://github.com/your-repo/studyflow.git
cd studyflow

# Install dependencies
flutter pub get

# Run in development mode
flutter run -d linux
```

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── course.dart          # Course, Assignment, Project models
├── screens/                  # UI screens
│   ├── dashboard_screen.dart
│   ├── course_detail_screen.dart
│   └── settings_screen.dart
├── widgets/                  # Reusable components
│   ├── course_card.dart
│   ├── assignment_item.dart
│   └── empty_state_widget.dart
├── providers/               # State management
│   ├── course_provider.dart
│   └── settings_provider.dart
└── services/               # Business logic
    ├── storage_service.dart
    └── backup_service.dart
```

### Building for Different Platforms

```bash
# Linux
flutter build linux --release

# Android APK
flutter build apk --release

# Web
flutter build web --release

# Windows (on Windows machine)
flutter build windows --release

# macOS (on macOS machine)
flutter build macos --release
```

## 🐛 Troubleshooting

### Common Issues

**Build Fails on Linux:**
```bash
# Install missing dependencies
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# Clean and rebuild
flutter clean
flutter pub get
flutter build linux --release
```

**App Won't Start:**
```bash
# Check library dependencies
ldd ~/.local/studyflow/studyflow

# Install missing GTK libraries
sudo apt-get install libgtk-3-0
```

**Permission Issues:**
```bash
# Fix executable permissions
chmod +x ~/.local/studyflow/studyflow

# Fix data directory permissions
chmod -R 755 ~/.local/studyflow/data/
```

**Flutter Not Found:**
```bash
# Add Flutter to PATH
echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
source ~/.bashrc
```

### Getting Help

- **Flutter Documentation**: https://flutter.dev/docs
- **Issues**: Report bugs on our GitHub issues page
- **Discussions**: Join our community discussions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/) framework
- Icons from [Material Design Icons](https://material.io/icons/)
- Inspired by modern student productivity needs

---

**StudyFlow** - Organize your academic journey with ease! 🎓✨