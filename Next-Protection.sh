#!/bin/bash

echo -e "\033[1;33mInstalling SUPER DDoS Protection with Auto-Block System...\033[0m"

# Install required packages
apt update -y
apt install -y iptables ipset iptables-persistent net-tools figlet curl lsb-release

# Create IP sets
ipset create ddos-block hash:ip timeout 3600 2>/dev/null || true
ipset create port-scan hash:ip timeout 1800 2>/dev/null || true

# Flush existing rules
iptables -F
iptables -X

# Allow localhost and established connections
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# === AUTO-BLOCK SYSTEM === #

# SYN Flood Protection
iptables -N SYN-FLOOD
iptables -A INPUT -p tcp --syn -j SYN-FLOOD
iptables -A SYN-FLOOD -m limit --limit 10/second --limit-burst 20 -j RETURN
iptables -A SYN-FLOOD -j SET --add-set ddos-block src

# UDP Flood Protection
iptables -A INPUT -p udp -m limit --limit 5/second --limit-burst 10 -j ACCEPT
iptables -A INPUT -p udp -j SET --add-set ddos-block src

# ICMP Flood Protection
iptables -A INPUT -p icmp -m limit --limit 1/second --limit-burst 5 -j ACCEPT
iptables -A INPUT -p icmp -j SET --add-set ddos-block src

# Too many connections
iptables -A INPUT -p tcp --syn -m connlimit --connlimit-above 40 -j SET --add-set ddos-block src

# Port Scan Detection
for port in 21 22 23 25 3306 3389 8080; do
  iptables -A INPUT -p tcp --dport $port -m recent --set --name scanner
  iptables -A INPUT -p tcp --dport $port -m recent --update --seconds 60 --hitcount 5 --rttl --name scanner -j SET --add-set port-scan src
done

# Drop blocked IPs
iptables -A INPUT -m set --match-set ddos-block src -j DROP
iptables -A INPUT -m set --match-set port-scan src -j DROP

# Save rules
netfilter-persistent save

# === ddos-status Command ===
cat > /usr/local/bin/ddos-status << 'EOF'
#!/bin/bash
clear
echo -e "\033[1;33m"
figlet "DDOS STATUS"
echo -e "\033[0m"
echo -e "\033[93m🔥 Next Development & DDOS Protection ⚡"
echo -e "         🚡 MADE BY NINJA (SUPAR DEV)\033[0m"
echo ""

echo -e "\033[96m=== VPS STATUS ===\033[0m"
echo "Uptime     : $(uptime -p)"
echo "OS Version : $(lsb_release -ds || head -n 1 /etc/os-release)"
echo "Kernel     : $(uname -r)"
echo ""

echo -e "\033[91m=== BLOCKED IPs (DDoS) ===\033[0m"
ipset list ddos-block 2>/dev/null | grep -E '^[0-9.]' || echo "None"

echo -e "\033[91m=== BLOCKED IPs (Scanners) ===\033[0m"
ipset list port-scan 2>/dev/null | grep -E '^[0-9.]' || echo "None"

echo ""
echo -e "\033[95m=== TOP LIVE CONNECTIONS ===\033[0m"
netstat -ntu | awk '{print $5}' | cut -d: -f1 | grep -Eo '^[0-9.]+' | sort | uniq -c | sort -nr | head -10
echo ""
echo -e "\033[90m[Use Ctrl+C to exit]\033[0m"
EOF

chmod +x /usr/local/bin/ddos-status

# === block-ip Command ===
cat > /usr/local/bin/block-ip << 'EOF'
#!/bin/bash

IP="$1"
if [[ -z "$IP" ]]; then
  echo "Usage: block-ip <ip-address>"
  exit 1
fi

ipset add ddos-block "$IP" timeout 3600 2>/dev/null
if [[ $? -eq 0 ]]; then
  echo "[✓] IP $IP has been manually blocked for 1 hour."
else
  echo "[!] IP $IP is already blocked or invalid."
fi
EOF

chmod +x /usr/local/bin/block-ip

# === unblock-ip Command ===
cat > /usr/local/bin/unblock-ip << 'EOF'
#!/bin/bash

IP="$1"
if [[ -z "$IP" ]]; then
  echo "Usage: unblock-ip <ip-address>"
  exit 1
fi

ipset del ddos-block "$IP" 2>/dev/null
ipset del port-scan "$IP" 2>/dev/null

if [[ $? -eq 0 ]]; then
  echo "[✓] IP $IP has been unblocked."
else
  echo "[!] IP $IP was not in block list."
fi
EOF

chmod +x /usr/local/bin/unblock-ip

# === Final Message ===
echo -e "\033[32m✅ Auto-Blocking DDoS Protection Installed!"
echo -e "Use \033[1mddos-status\033[0m to view live attack status."
echo -e "Use \033[1mblock-ip <ip>\033[0m to manually block any IP."
echo -e "Use \033[1munblock-ip <ip>\033[0m to remove a blocked IP.\033[0m"
