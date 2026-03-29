#!/bin/bash
# Battery Manager - Installation Script
# Copies systemd files and creates symlinks for scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Installing Battery Manager from: $SCRIPT_DIR"

# Check and install TLP if not present
echo "→ Checking for TLP..."
if ! command -v tlp &> /dev/null && ! [ -f /usr/bin/tlp ]; then
    echo "  TLP not found, installing..."
    if command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm tlp tlp-rdw
    elif command -v apt &> /dev/null; then
        sudo apt install -y tlp tlp-rdw
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y tlp tlp-rdw
    else
        echo "Error: Package manager not found. Please install TLP manually."
        exit 1
    fi
    echo "  TLP installed successfully"
else
    echo "  TLP is already installed"
fi

# Copy systemd files
echo "→ Copying systemd files..."
sudo cp "$SCRIPT_DIR/battery-monitor.service" /etc/systemd/system/
sudo cp "$SCRIPT_DIR/battery-monitor.timer" /etc/systemd/system/

# Copy Python script to system location
echo "→ Installing battery-monitor.py..."
sudo cp "$SCRIPT_DIR/battery-monitor.py" /usr/local/bin/battery-monitor.py
sudo chmod +x /usr/local/bin/battery-monitor.py

# Create symlinks in /usr/local/bin for easy access
echo "→ Creating symlinks..."
sudo ln -sf "$SCRIPT_DIR/battery-monitor.py" /usr/local/bin/battery-monitor
sudo ln -sf "$SCRIPT_DIR/battery-check.py" /usr/local/bin/battery-check

# Reload systemd
echo "→ Reloading systemd..."
sudo systemctl daemon-reload

# Enable and start timer
echo "→ Enabling battery-monitor.timer..."
sudo systemctl enable battery-monitor.timer
sudo systemctl start battery-monitor.timer

# Initialize TLP config
echo "→ Initializing TLP config..."
sudo python3 /usr/local/bin/battery-monitor.py

echo ""
echo "✓ Installation complete!"
echo ""
echo "Usage:"
echo "  battery-check     - Check battery and TLP status"
echo "  battery-monitor   - Manually trigger profile switch"
echo "  battery-check.py  - Same as battery-check (direct script)"
echo ""
echo "Systemd timer runs every 2 minutes automatically"
