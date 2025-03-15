# AutoVNT

AutoVNT is an installer utility for automatically deploying and configuring `vnt-cli` services for Linux and macOS systems.

## 📦 Features
- Easy installer scripts
- Auto configuration generation
- Systemd (Linux) & Launchd (macOS) support

## 📂 Project Structure
```
install/
├── install_linux.sh
├── install_macos.sh
└── helpers/
    └── config_gen.sh
```

## 📖 Usage Guide
👉 See [docs/USAGE.md](docs/USAGE.md) for detailed instructions.

```shell
cd install
./install_linux.sh
```

## test

test on linux, support latest windows wsl2(support systemctl tools)

## ☁️ CDN Installation (Optional)
```bash
curl -fsSL https://cdn.example.com/AutoVNT/install_linux.sh | sudo bash
```
> Replace `https://cdn.example.com/AutoVNT/install_linux.sh` with your actual CDN URL.

## 🧩 Configuration Example
```yaml
device_id: <generated>
token: 22d8b6dc
name: my-device
ip: 192.168.1.100
server_address: vnt.example.com:29872
server_encrypt: true
device_name: vnt-tun
cipher_model: aes_gcm
finger: false
use_channel: p2p
cmd: false
tcp: true
dns:
  - 223.5.5.5
  - 8.8.8.8
```

## 📄 License
MIT

