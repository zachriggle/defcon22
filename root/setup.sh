#!/bin/bash

# Update and install prerequisites
apt-get -y update
[ -z "$TRAVIS" ] && apt-get -y upgrade
apt-get -y install git qemu qemu-user qemu-user-static binfmt-support
apt-get -y install libc6-i386 libc6-armhf-cross xinetd

# DEFCON 22 challenges require /dev/ctf
ln -s /dev/urandom /dev/ctf

# By default, everything should be owned by root, and read-only.
chmod 700 /root
for file in $(git ls-files); do
    chown root:root $file
done
for file in $(git ls-files -- etc/sudoers.d); do
    chmod 0440 $file
done
for file in $(git ls-files -- usr); do
    chmod +rx $file
done

USERS=(eliza imap wdub justify)

# Each
for user in ${USERS[@]}; do
  useradd -m $user
  passwd  -l $user

  # Everything inside of the home directory should belong to the user
  chown -R $user:$user /home/$user
  chmod -R ug=rw,o=    /home/$user

  # The home directory itself is owned by root, so that it cannot be deleted.
  chown    root:$user  /home/$user
  chmod    1770        /home/$user

  # The service binary should be owned by the CTF user, so that it cannot
  # be modified or deleted.
  if [ -e /home/$user/$user ];
  then
    chown    ctf:ctf     /home/$user/$user
    chmod    0755        /home/$user/$user
  fi
done

# Kickstart xinetd
service xinetd restart

# Everything below this line is optional hardening
apt-get -yq remove kexec-tools
apt-get -yq install fail2ban kpartx unattended-upgrades
rm -f /boot/System.map*

# Disable 'last'
chmod o-r /var/*/{btmp,wtmp,utmp}


