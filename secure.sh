#!/bin/sudo bash
#-----------------------
#--Required Packages-
#-ufw
#-fail2ban

# --- Setup UFW rules
if [[ -f /usr/sbin/ufw ]]; then
    ufw limit 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw default deny incoming
    ufw default allow outgoing
    ufw enable
else
    echo "ufw not found"
fi

# --- Harden /etc/sysctl.conf
if [[ -f /usr/sbin/sysctl ]]; then
#    sysctl kernel.modules_disabled=1
    sysctl -a
    sysctl mib
    sysctl net.ipv4.conf.all.rp_filter
    sysctl -a --pattern 'net.ipv4.conf.(eth|wlan)0.arp'
else
    echo "sysctl not found"
fi

# --- PREVENT IP SPOOFS
cat << EOF > /etc/host.conf
order bind,hosts
multi on
EOF

# --- Enable fail2ban
cp jail.local /etc/fail2ban/
systemctl enable fail2ban
systemctl start fail2ban

echo "listening ports"
netstat -tunlp
