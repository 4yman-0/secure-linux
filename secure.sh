#!/usr/bin/env bash
#-----------------------
#--Required Packages-
#-ufw
#-fail2ban

# get sudo
if [ $UID -ne 0 ]; then
    exec sudo "$0" "$@"
fi

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
    sysctl fs.protected_hardlinks=1
    sysctl fs.protected_symlinks=1
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
