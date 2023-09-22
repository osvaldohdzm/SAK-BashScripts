#!/bin/bash

# Check if the script is run with root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
fi

# Function to check and install a package
check_and_install_package() {
    package_name="$1"
    if ! dpkg -l | grep -q "$package_name"; then
        echo "Installing $package_name..."
        apt install -y "$package_name"
    else
        echo "$package_name is already installed."
    fi
}

# Function to create or update the .desktop file for P3X OneNote
create_or_update_desktop_file() {
    desktop_file="/usr/share/applications/p3x-onenote.desktop"
    if [ ! -f "$desktop_file" ]; then
        echo "Creating new .desktop file for P3X OneNote..."
        cat <<EOF >"$desktop_file"
[Desktop Entry]
Name=P3X OneNote
Comment=Microsoft OneNote on Linux
Exec=p3x-onenote
Icon=/snap/p3x-onenote/current/icon.png
Terminal=false
Type=Application
Categories=Office;
EOF
    else
        echo "Updating existing .desktop file for P3X OneNote..."
        sed -i '/Exec=/c\Exec=p3x-onenote' "$desktop_file"
    fi
}

# Update system packages
echo "Step 1: Updating Packages..."
apt update -y

# Install or upgrade packages
check_and_install_package "kali-linux-large"
apt upgrade -y
check_and_install_package "openvpn"
check_and_install_package "git"

# Install Snap package manager (if not already installed)
if ! snap --version &> /dev/null; then
    echo "Step 2: Installing Snap Package Manager..."
    apt install -y snapd
    systemctl start snapd
    systemctl enable snapd.socket
    systemctl start snapd.socket
    systemctl status snapd.socket
else
    echo "Snap Package Manager is already installed."
fi

# Check if /snap/bin is already in the PATH
if [[ ":$PATH:" == *":/snap/bin:"* ]]; then
    echo "/snap/bin is already in your PATH."
else
    # Add /snap/bin to the PATH in ~/.bashrc
    echo 'export PATH="/snap/bin:$PATH"' >> ~/.bashrc
    echo "/snap/bin has been added to your PATH in ~/.bashrc."
    echo "You may need to restart your shell or open a new terminal for the changes to take effect."
fi

# Install P3X OneNote if not already installed
if ! snap list | grep -q "p3x-onenote"; then
    echo "Step 3: Installing P3X OneNote..."
    snap install p3x-onenote
else
    echo "P3X OneNote is already installed."
fi

# Create or update the .desktop file for P3X OneNote
create_or_update_desktop_file

echo "P3X OneNote installation and .desktop file setup completed."
echo "You can launch it from the XFCE Applications Menu in the 'Office' section."



apt update 
apt full-upgrade -y
curl -fsSL https://www.virtualbox.org/download/oracle_vbox_2016.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/oracle_vbox_2016.gpg\n
curl -fsSL https://www.virtualbox.org/download/oracle_vbox.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/oracle_vbox.gpg\n
echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bullseye contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list\n
apt update
apt install linux-headers-$(uname -r) dkms -y
apt install virtualbox virtualbox-ext-pack -y 
apt install preload
systemctl status preload
apt install tlp tlp-rdw\n
tlp start\n
systemctl enable tlp.service
systemctl disable bluetooth.service
systemctl disable cups.service
systemctl disable netdata.service



systemd-analyze blame
systemctl disable ModemManager.service \n
systemctl mask ModemManager.service \n
systemctl disable cups.service
systemd-analyze time
                               
echo "vm.swappiness=0" >> /etc/sysctl.d/60-custom.conf
sudo sysctl -p /etc/sysctl.d/60-custom.conf
sudo swapoff -a


apt install compizconfig-settings-manager -y
#compiz --replace
