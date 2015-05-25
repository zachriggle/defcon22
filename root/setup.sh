#!/bin/bash
apt-get install git qemu qemu-user qemu-user-static binfmt
apt-get install libc6-i386 libc6-armhf-cross xinetd

for user in ctf eliza imap wdub justify; do
  useradd -m $user
  passwd  -l $user
  chown -R $user:$user /home/$user
  chown    root:$user  /home/$user
  chmod 1770 /home/$user
  chmod +x /home/$user/$user
done

pushd /root
wget http://launchpadlibrarian.net/158174573/libpcre3_8.31-2ubuntu2_armhf.deb
wget http://launchpadlibrarian.net/185771211/libglib2.0-0_2.40.2-0ubuntu1_armhf.deb
dpkg -x libpcre3_8.31-2ubuntu2_armhf.deb out
dpkg -x libglib2.0-0_2.40.2-0ubuntu1_armhf.deb out
cp out/lib/arm-linux-gnueabihf/* /usr/arm-linux-gnueabihf/lib
popd

service xinetd restart


# Everything below this line is optional hardening
apt-get -yq remove kexec-tools
apt-get -yq install fail2ban kpartx unattended-upgrades
rm -f /boot/System.map*

cat > /etc/default/kexec << EOF
LOAD_EXEC=false
EOF

cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
        "Ubuntu trusty-security";
        "Ubuntu trusty-updates";
};
EOF
cat > /etc/apt/apt.conf.d/10periodic << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Unattended-Upgrade::Automatic-Reboot "true";
EOF

# Have to leave symlink stuff on for challenges.
cat > /etc/sysctl.d/99-ctf.conf << EOF
# fs.protected_hardlinks = 1
# fs.protected_symlinks = 1
kernel.kptr_restrict = 1
kernel.perf_event_paranoid = 2
kernel.randomize_va_space = 2
kernel.yama.ptrace_scope = 1
net.ipv4.tcp_syncookies = 1
net.ipv6.conf.all.disable_ipv6 = 1
kernel.core_pattern = core
EOF
sysctl --system

# Disable 'last'
chmod o-r /var/*/{btmp,wtmp,utmp}


