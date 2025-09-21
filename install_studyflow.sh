#!/bin/bash

echo "🎓 StudyFlow Installation Script"
echo "================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
echo -e "${BLUE}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed. Installing Flutter...${NC}"

    # Install Flutter via snap
    echo -e "${YELLOW}Installing Flutter SDK...${NC}"
    sudo snap install flutter --classic

    # Add Flutter to PATH
    echo 'export PATH="$PATH:/snap/bin"' >> ~/.bashrc
    source ~/.bashrc

    echo -e "${GREEN}Flutter installed successfully!${NC}"
else
    echo -e "${GREEN}Flutter is already installed.${NC}"
fi

# Install Linux desktop dependencies
echo -e "${BLUE}Installing Linux desktop dependencies...${NC}"
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libblkid-dev

# Enable Linux desktop support
echo -e "${BLUE}Enabling Linux desktop support...${NC}"
flutter config --enable-linux-desktop

# Check if we're in the StudyFlow project directory
if [ -f "pubspec.yaml" ] && grep -q "studyflow" pubspec.yaml; then
    echo -e "${GREEN}Found StudyFlow project in current directory.${NC}"
    PROJECT_DIR=$(pwd)
else
    echo -e "${YELLOW}StudyFlow project not found in current directory.${NC}"
    echo -e "${BLUE}Please navigate to the StudyFlow project directory and run this script again.${NC}"
    echo -e "${BLUE}Or copy the project files to a new directory first.${NC}"

    # Create project directory and basic structure
    PROJECT_DIR="$HOME/StudyFlow"
    echo -e "${BLUE}Creating basic StudyFlow project at $PROJECT_DIR...${NC}"
    mkdir -p "$PROJECT_DIR"
    cd "$PROJECT_DIR"

    # Initialize Flutter project
    flutter create studyflow_app --project-name studyflow
    cd studyflow_app
    PROJECT_DIR="$PROJECT_DIR/studyflow_app"
fi

cd "$PROJECT_DIR"

# Install dependencies
echo -e "${BLUE}Installing Flutter dependencies...${NC}"
flutter pub get

# Build the app
echo -e "${BLUE}Building StudyFlow for Linux...${NC}"
flutter build linux --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"

    # Create installation directory
    INSTALL_DIR="$HOME/.local/studyflow"
    echo -e "${BLUE}Installing StudyFlow to $INSTALL_DIR...${NC}"

    mkdir -p "$INSTALL_DIR"
    cp -r build/linux/x64/release/bundle/* "$INSTALL_DIR/"

    # Make executable
    chmod +x "$INSTALL_DIR/studyflow"

    # Create desktop entry
    DESKTOP_FILE="$HOME/.local/share/applications/studyflow.desktop"
    mkdir -p "$(dirname "$DESKTOP_FILE")"

    cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=StudyFlow
Comment=Modern student task manager for organizing courses, assignments, and study sessions
Exec=$INSTALL_DIR/studyflow
Icon=applications-education
Terminal=false
Type=Application
Categories=Education;Office;
StartupWMClass=studyflow
Keywords=study;course;assignment;student;education;task;manager;
EOF

    # Update desktop database
    update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

    # Create command line launcher
    LAUNCHER="$HOME/.local/bin/studyflow"
    mkdir -p "$(dirname "$LAUNCHER")"

    cat > "$LAUNCHER" << EOF
#!/bin/bash
cd "$INSTALL_DIR"
./studyflow "\$@"
EOF

    chmod +x "$LAUNCHER"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo -e "${YELLOW}Added ~/.local/bin to PATH. Restart terminal or run: source ~/.bashrc${NC}"
    fi

    echo -e "${GREEN}✅ StudyFlow installed successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📱 How to run StudyFlow:${NC}"
    echo -e "1. ${BLUE}From desktop menu:${NC} Look for 'StudyFlow' in your applications menu"
    echo -e "2. ${BLUE}From terminal:${NC} Type 'studyflow' (after restarting terminal)"
    echo -e "3. ${BLUE}Direct path:${NC} $INSTALL_DIR/studyflow"
    echo ""
    echo -e "${GREEN}🎉 Features available:${NC}"
    echo -e "  📚 Course management with progress tracking"
    echo -e "  📝 Assignment and project organization"
    echo -e "  📖 3-phase lecture system (Read → Practice → Finalize)"
    echo -e "  💾 Data export/import for backups"
    echo -e "  🌙 Dark theme support"
    echo -e "  🔒 Persistent data storage"
    echo ""

    # Ask if user wants to run it now
    read -p "Would you like to run StudyFlow now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Starting StudyFlow...${NC}"
        cd "$INSTALL_DIR"
        ./studyflow &
        echo -e "${GREEN}StudyFlow is starting! Check your desktop.${NC}"
        echo -e "${YELLOW}If it doesn't appear, you may need to install additional GTK libraries:${NC}"
        echo -e "  sudo apt-get install libgtk-3-0"
    fi

else
    echo -e "${RED}❌ Build failed. Please check the error messages above.${NC}"
    echo -e "${YELLOW}Common solutions:${NC}"
    echo -e "1. Make sure all dependencies are installed:"
    echo -e "   sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev"
    echo -e "2. Check Flutter setup: flutter doctor"
    echo -e "3. Clean and retry: flutter clean && flutter pub get"
    exit 1
fi

echo ""
echo -e "${GREEN}🎓 Welcome to StudyFlow! Organize your academic journey with ease.${NC}"