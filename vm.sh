#!/bin/sh
# bash script designed to be downloaded by autoeexec
# by Tom Schreiner <tom.schreiner@gmx.de>
# CONTENTS
# TBD

installpkg(){
  pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}

#installinf ohmyzsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

for x in xf86-video-vesa xorg-server xorg-xinit; do
  dialog --title "installing..." --infobox "Installing $x" 10 50
  installpkg "$x"
done

cd
git clone --recurse-submodules https://github.com/fairyglade/ly
cd ly
make
make run
make installsystemd
systemctl enable ly.service
cd
rm ly