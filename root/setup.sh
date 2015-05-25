#!/bin/sh
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
