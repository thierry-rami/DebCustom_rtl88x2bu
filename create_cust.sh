#!/bin/bash
# version debian courante
debver="12.2.0"
# tous est dans ~DevIso
# creation des Dossiers
mkdir DevIso
cd DevIso
mkdir Iso tmp
mkdir -p debrtl/rtl88x2bu/usr/src/rtl88x2bu-git

mkdir debrtl/rtl88x2bu/DEBIAN

# tous va etre téléchargé dans tmp
cd tmp
# on recupere l'iso DVD install Debian
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-$debver-amd64-DVD-1.iso
# extraction du DVD dans Iso/
bsdtar -C ../Iso/ -xf debian-$debver-amd64-DVD-1.iso

# on recupere le boot du DVD
dd if=debian-$debver-amd64-DVD-1.iso bs=1 count=432 of=../isohdpfx.bin

wget https://github.com/RinCat/RTL88x2BU-Linux-Driver/archive/refs/heads/master.zip
bsdtar -xf master.zip -s'|[^/]*/||' -C ../debrtl/rtl88x2bu/usr/src/rtl88x2bu-git
