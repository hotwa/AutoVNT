#!/bin/bash
set -e

VNT_VERSION="v1.2.16"
VNT_TARBALL="vnt-x86_64-apple-darwin-${VNT_VERSION}.tar.gz"
VNT_URL="https://github.com/vnt-dev/vnt/releases/download/${VNT_VERSION}/${VNT_TARBALL}"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/usr/local/etc/rustvnt"
CONFIG_FILE="${CONFIG_DIR}/config.yml"
SERVICE_FILE="/Library/LaunchDaemons/com.example.vnt-cli.plist"
LOG_FILE="/var/log/vnt-cli.log"
ERR_FILE="/var/log/vnt-cli.err"

usage() {
    echo "Usage: $0 {install|uninstall}"
    exit 1
}

if [ "$#" -ne 1 ]; then usage; fi

if [ "$1" = "install" ]; then
    echo "==> Installing VNT CLI..."
    curl -L -o "$VNT_TARBALL" "$VNT_URL"
    tar zxvf "$VNT_TARBALL"
    sudo mv vnt-cli "$INSTALL_DIR/"
    sudo chmod +x "$INSTALL_DIR/vnt-cli"
    rm -f "$VNT_TARBALL"

    sudo mkdir -p "$CONFIG_DIR"
    read -p "Enter VNT server address: " SERVER_ADDR
    read -p "Enter local IP address: " IP_ADDR
    read -p "Enter device name: " DEVICE_NAME
    read -p "Enter token [default: 22d8b6dc]: " TOKEN
    TOKEN=${TOKEN:-22d8b6dc}
    DEVICE_ID=$(uuidgen)

    for i in $(seq 0 255); do
        CANDIDATE="utun${i}"
        if ! ifconfig | grep -q "$CANDIDATE"; then
            INTERFACE="$CANDIDATE"
            break
        fi
    done

    sudo tee "$CONFIG_FILE" > /dev/null <<EOF
device_id: ${DEVICE_ID}
token: ${TOKEN}
name: ${DEVICE_NAME}
ip: ${IP_ADDR}
server_address: ${SERVER_ADDR}
server_encrypt: true
device_name: ${INTERFACE}
cipher_model: aes_gcm
finger: false
use_channel: p2p
cmd: false
tcp: true
dns:
  - 223.5.5.5
  - 8.8.8.8
EOF

    sudo tee "$SERVICE_FILE" > /dev/null <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.vnt-cli</string>
    <key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}/vnt-cli</string>
        <string>-f</string>
        <string>${CONFIG_FILE}</string>
    </array>
    <key>WorkingDirectory</key>
    <string>${INSTALL_DIR}</string>
    <key>StandardOutPath</key>
    <string>${LOG_FILE}</string>
    <key>StandardErrorPath</key>
    <string>${ERR_FILE}</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>NetworkState</key>
        <true/>
    </dict>
    <key>ThrottleInterval</key>
    <integer>5</integer>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>RUST_BACKTRACE</key>
        <string>1</string>
    </dict>
</dict>
</plist>
EOF

    sudo chown root:wheel "$SERVICE_FILE"
    sudo chmod 644 "$SERVICE_FILE"
    sudo launchctl load -w "$SERVICE_FILE"
    echo "✅ Installed and launched VNT CLI service."
elif [ "$1" = "uninstall" ]; then
    sudo launchctl bootout system "$SERVICE_FILE" || true
    sudo rm -f "$SERVICE_FILE"
    sudo rm -f "${INSTALL_DIR}/vnt-cli"
    sudo rm -rf "$CONFIG_DIR"
    sudo rm -f "$LOG_FILE" "$ERR_FILE"
    echo "✅ Uninstalled VNT CLI service."
else
    usage
fi
