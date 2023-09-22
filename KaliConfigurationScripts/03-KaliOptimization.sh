#!/bin/bash

# This script performs various optimizations on a Kali Linux system.

echo -e "Optimizing Kali Linux...\n"

# Detect the current desktop environment (assuming you have either GNOME or XFCE installed).
desktop_environment="$(echo $XDG_CURRENT_DESKTOP)"

# Common optimizations
echo -e "Common optimizations..."

# Update and Upgrade Packages
echo -e "Updating and upgrading packages...\n"
sudo apt update
sudo apt upgrade -y
echo -e "Package update and upgrade complete.\n"

# Clean Up Unnecessary Packages
echo -e "Cleaning up unnecessary packages...\n"
sudo apt autoremove -y
sudo apt clean
echo -e "Package cleanup complete.\n"

# Check for Broken Dependencies
echo -e "Checking for broken dependencies...\n"
sudo apt --fix-broken install -y
echo -e "Broken dependency check complete.\n"

# Remove Unused Kernel Versions
echo -e "Removing unused kernel versions...\n"
sudo apt purge -y $(dpkg -l | awk '/^ii linux-image-*/{print $2}' | grep -v $(uname -r))
echo -e "Unused kernel versions removed.\n"

# Optimize Swap Usage
echo -e "Optimizing swap usage...\n"
sudo sysctl vm.swappiness=10
echo -e "Swap optimization complete.\n"

# Clear Cached Memory
echo -e "Clearing cached memory...\n"
sudo sync
sudo echo 3 > /proc/sys/vm/drop_caches
echo -e "Cached memory cleared.\n"

# Monitoring System Resources
echo -e "Monitoring system resources...\n"
sudo apt install -y htop
echo -e "System resource monitoring complete.\n"

# Disable visual effects for specific desktop environments
echo -e "Disabling visual effects...\n"

if [ "$desktop_environment" = "GNOME" ]; then
    # GNOME-specific optimizations
    echo -e "GNOME-specific optimizations..."

    # Disable Window Animations
    gsettings set org.gnome.desktop.interface enable-animations false
    echo -e "Window animations disabled.\n"

    # Disable Background Image
    gsettings set org.gnome.desktop.background show-desktop-icons true
    echo -e "Background image disabled.\n"

    # Disable Desktop Effects
    gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps false
    gsettings set org.gnome.desktop.interface enable-hot-corners false
    echo -e "Desktop effects disabled for GNOME.\n"

    # Reduce Transparency
    gsettings set org.gnome.desktop.interface enable-animations false
    echo -e "Transparency effects disabled for GNOME.\n"
    
    echo -e "Visual effects have been disabled for GNOME.\n"

elif [ "$desktop_environment" = "XFCE" ]; then
    # XFCE-specific optimizations
    echo -e "XFCE-specific optimizations..."
    
    echo -e "Visual effects have been disabled for XFCE (customize as needed).\n"

else
    # If the desktop environment is not GNOME or XFCE, add customizations here.
    echo -e "No specific optimizations for the detected desktop environment: $desktop_environment.\n"

fi



# Check if Brave browser is installed
if command -v brave-browser &> /dev/null; then
    # Brave configuration directory
    brave_config_dir=~/.config/BraveSoftware/Brave-Browser

    # Flags to enable
    flags=(
        "experimental-quic"
        "enable-quic"
        "enable-experimental-web-platform-features"
        "enable-gpu-rasterization"
        "override-software-rendering-list"
        "enable-zero-copy"
        "enable-zero-copy-video-capture"
    )

    # Function to enable a flag
    enable_flag() {
        local flag_name="$1"
        local flag_value="$2"

        sed -i "s/\"$flag_name\": {[^}]*}/\"$flag_name\": { \"enabled\": $flag_value }/" "$brave_config_dir/Preferences"
    }

    # Enable each flag
    for flag in "${flags[@]}"; do
        enable_flag "brave://flags/#$flag" true
    done

    # Lock the Preferences file to make changes permanent
    chmod 400 "$brave_config_dir/Preferences"

    # Restart Brave
    echo "Flags enabled. Restarting Brave browser..."
    pkill -o -USR1 brave
    echo "Brave browser restarted."
else
    echo "Brave not installed already. Flags not enabled."
fi

xset -dpms
xset s off


echo -e "Optimization process completed.\n"





