#!/bin/bash
# version debian courante
debver="12.2.0"
diriso="DevIso"
# tous est dans ~DevIso 
# creation des Dossiers
mkdir ~/$diriso
cd ~/$diriso
mkdir Iso tmp
mkdir -p debrtl/rtl88x2bu/usr/src/rtl88x2bu-git
mkdir    debrtl/rtl88x2bu/DEBIAN

# tous va etre téléchargé dans tmp
cd tmp

# on recupere l'iso DVD install Debian
wget https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-$debver-amd64-DVD-1.iso

# extraction du DVD dans Iso/
bsdtar -C ~/$diriso/Iso/ -xf debian-$debver-amd64-DVD-1.iso
chmod -R +w ~/$diriso/Iso

# on change le splashscreen
cp  ~/DebCustom_rtl88x2bu/splash.png ~/$diriso/Iso/isolinux/splash.png

# on recupere le boot du DVD
dd if=debian-$debver-amd64-DVD-1.iso bs=1 count=432 of=~/$diriso/isohdpfx.bin
rm debian-$debver-amd64-DVD-1.iso

# on recupere les fichiers sources du driver
wget https://github.com/RinCat/RTL88x2BU-Linux-Driver/archive/refs/heads/master.zip
bsdtar -xf master.zip -s'|[^/]*/||' -C ~/$diriso/debrtl/rtl88x2bu/usr/src/rtl88x2bu-git
# on copie les config pour creation paquet et on  build le deb
cp -r ~/DebCustom_rtl88x2bu/debrtl/rtl88x2bu/DEBIAN/. ~/$diriso/debrtl/rtl88x2bu/DEBIAN/.
dpkg-deb --build  ~/$diriso/debrtl/rtl88x2bu
# on copie le deb dans l'arboresence du DVD
mkdir ~/$diriso/Iso/pool/main/r/rtl88x2bu
cp ~/$diriso/debrtl/*.deb ~/$diriso/Iso/pool/main/r/rtl88x2bu

# on crée et on applique le "config-deb"
cp ~/DebCustom_rtl88x2bu/config-deb ~/$diriso
cd ~/$diriso
apt-ftparchive generate config-deb
# on efface les MD5
sed -i '/MD5Sum:/,$d' Iso/dists/bookworm/Release
apt-ftparchive release Iso/dists/bookworm >> Iso/dists/bookworm/Release

# on genere les MD5
cd Iso; md5sum `find ! -name "md5sum.txt" ! -path "./isolinux/*" -follow -type f` > md5sum.txt; cd ..
# on rend le dossier en lecture
chmod -R -w Iso
# on genere le DVD
xorriso -as mkisofs -o Debian-12-Custom.iso -isohybrid-mbr isohdpfx.bin \
-c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table ./Iso
