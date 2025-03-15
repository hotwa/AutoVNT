#!/bin/bash

generate_config() {
  local file_path="$1"
  local device_id="$2"
  local token="$3"
  local name="$4"
  local ip="$5"
  local server="$6"
  local device_name="$7"

  cat <<EOF > "$file_path"
device_id: ${device_id}
token: ${token}
name: ${name}
ip: ${ip}
server_address: ${server}
server_encrypt: true
device_name: ${device_name}
cipher_model: aes_gcm
finger: false
use_channel: p2p
cmd: false
tcp: true
dns:
  - 223.5.5.5
  - 8.8.8.8
EOF
}
