#!/bin/bash
set -e  # Exit on any error

echo "=== INSTALLING GNOME DESKTOP ==="

# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install GNOME (minimal for speed)
sudo apt-get install -y --no-install-recommends \
    ubuntu-desktop-minimal \
    gnome-terminal \
    nautilus \
    firefox \
    xrdp

echo "=== CONFIGURING RDP FOR YOUR PHONE (720x1612) ==="

# Create user if not exists
if ! id "rduser" &>/dev/null; then
    sudo useradd -m -s /bin/bash rduser
    echo "rduser:Ubuntu123" | sudo chpasswd
    sudo usermod -aG sudo rduser
    echo "User rduser created"
fi

# Configure RDP for your exact screen size
sudo tee /etc/xrdp/xrdp.ini > /dev/null <<EOF
[globals]
bitmap_cache=yes
bitmap_compression=yes
port=3389
crypt_level=low
channel_code=1

[xrdp1]
name=GNOME-Desktop
lib=libvnc.so
username=rduser
password=Ubuntu123
ip=127.0.0.1
port=3389
width=720
height=1440  # Optimized for 720x1612 aspect ratio
EOF

# Set GNOME session
sudo mkdir -p /home/rduser
sudo tee /home/rduser/.xsession > /dev/null <<EOF
#!/bin/bash
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
exec gnome-session
EOF

sudo chown rduser:rduser /home/rduser/.xsession
sudo chmod +x /home/rduser/.xsession

# Fix permissions
sudo chown -R rduser:rduser /home/rduser

echo "=== STARTING RDP SERVICE ==="
sudo systemctl enable xrdp
sudo systemctl start xrdp

echo "=== SETUP COMPLETE ==="
echo "Screen resolution: 720x1440 (optimized for 720x1612 phone)"
echo "RDP User: rduser"
echo "RDP Pass: Ubuntu123"
echo "RDP Port: 3389"
