# 🛡️ SUPER DDoS Protection Script

A powerful and lightweight DDoS protection system for Linux servers using `iptables` and `ipset`. This script automatically detects and blocks common attack types, including SYN floods, UDP floods, ICMP floods, port scans, and connection abuse.

---

## 🔧 Features

- ✅ **Auto-detection & blocking** of:
  - SYN flood attacks
  - UDP floods
  - ICMP floods
  - Excessive TCP connections
  - Port scanning (21, 22, 23, 25, 3306, 3389, 8080)
- 📊 `ddos-status`: View blocked IPs, system uptime, and top live connections.
- 🧱 `block-ip <ip>`: Manually block an IP for 1 hour.
- 🛠️ `unblock-ip <ip>`: Unblock a manually or auto-blocked IP.
- 💾 Automatically saves iptables rules for reboot persistence.
- ⚡ Lightweight – no external DDoS services or agents required.

---

## 📦 Installation

1. Download the script:

```bash
bash <(curl -s https://raw.githubusercontent.com/next-ninja/Next-Protection/refs/heads/main/install.sh)
