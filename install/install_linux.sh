#!/bin/bash
set -e

source "$(dirname "$0")/helpers/config_gen.sh"

VNT_VERSION="v1.2.16"
VNT_TARBALL="vnt-x86_64-unknown-linux-musl-${VNT_VERSION}.tar.gz"
VNT_URL="https://github.com/vnt-dev/vnt/releases/download/${VNT_VERSION}/${VNT_TARBALL}"

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/root/.config/rustvnt"
CONFIG_FILE="${CONFIG_DIR}/config.yaml"
SERVICE_FILE="/etc/systemd/system/vnt-cli.service"

echo "==> Installing VNT CLI ${VNT_VERSION}..."
wget -q --show-progress "$VNT_URL"
tar zxvf "$VNT_TARBALL"
mv vnt-cli "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/vnt-cli"
rm -f "$VNT_TARBALL"

mkdir -p "$CONFIG_DIR"

echo "==> Collecting Configuration..."
read -p "Enter VNT server address: " SERVER_ADDR
read -p "Enter local IP address: " IP_ADDR
read -p "Enter device name: " DEVICE_NAME
read -p "Enter token [default: 22d8b6dc]: " TOKEN
TOKEN=${TOKEN:-22d8b6dc}
DEVICE_ID=$(uuidgen)

generate_config "$CONFIG_FILE" "$DEVICE_ID" "$TOKEN" "$DEVICE_NAME" "$IP_ADDR" "$SERVER_ADDR" "vnt-tun"

cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=VNT CLI Service
After=network.target

[Service]
ExecStart=${INSTALL_DIR}/vnt-cli -f ${CONFIG_FILE}
Restart=always
User=root
WorkingDirectory=${INSTALL_DIR}
StandardOutput=journal
StandardError=journal
Environment=PATH=/usr/local/bin:/usr/bin:/bin:/sbin:/usr/sbin:$PATH
Environment=RUST_BACKTRACE=1
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vnt-cli
systemctl start vnt-cli

echo "✅ VNT CLI Installed and Running."
