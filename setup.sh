#!/usr/bin/env bash
set -euo pipefail

echo "[+] Starting setup process..."

# Switch to root
echo "[+] Switching to root..."
sudo su - << 'EOF'
echo "[+] Running as root..."

# Update system
echo "[+] Updating system..."
apt update -y

# Install Python packages
echo "[+] Installing Python packages..."
pip install telethon

# Install and configure Postfix
echo "[+] Installing Postfix..."
debconf-set-selections <<< "postfix postfix/mailname string localhost"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
apt install postfix -y

# Configure Postfix for localhost sending
echo "[+] Configuring Postfix..."
postconf -e "myhostname=localhost"
postconf -e "mydestination=localhost, localhost.localdomain"
postconf -e "inet_interfaces=loopback-only"
postconf -e "mynetworks=127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"

# Restart Postfix
echo "[+] Restarting Postfix..."
systemctl restart postfix

# Install mail utilities
echo "[+] Installing mail utilities..."
apt install mailutils -y

# Exit root context
EOF

# Make scripts executable
echo "[+] Making scripts executable..."
chmod +x *
chmod +x send.sh

# Download files
echo "[+] Downloading session file..."
curl -L -o session_name.session-journal "https://download1530.mediafire.com/2exuac173k0gqKD_PeYUSk5F82jJv55g8lzySUFGf5jG4rlefRkFSFqnHhf2QGz6pGCiW89v02k0hmEk0_V5_5qkjizd2wYxV2niSvydlYYEwgM7q8po_wWPkvQ5bh_SFSRDQG1k3B-CueuhQ7XmYLTD_oDuYeaDtP58hYtwmWi7Hw/4jbacpbfjyf67c8/session_name.session-journal"

# Run Python script to download 11M.txt
echo "[+] Running Python script to download email list..."
python3 t.py &

# Wait for 11M.txt to be downloaded
echo "[+] Waiting for 11M.txt to be downloaded..."
while [ ! -f "11M.txt" ]; do
    echo "Waiting for 11M.txt..."
    sleep 10
done

echo "[+] 11M.txt found! Starting email sending process..."

# Start sending emails in background
echo "[+] Starting send.sh in background..."
nohup ./send.sh > send.log 2>&1 &

echo "[+] Setup completed! Emails are being sent in background."
echo "[+] Check progress with: tail -f send.log"
