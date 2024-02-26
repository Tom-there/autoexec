#!/bin/sh
# bash script designed to be downloaded by autoeexec
# by Tom Schreiner <tom.schreiner@gmx.de>
# CONTENTS
# TBD


# yayinstall(){
#  	whiptail --infobox "Installing 'yay' manually." 7 50
#  	sudo -u "$username" mkdir -p "$repodir/yay"
#  	sudo -u "$username" git -C "$repodir" clone --depth 1 --single-branch \
#  		--no-tags -q "https://aur.archlinux.org/yay.git" "$repodir/yay" ||
#  		{
#  			cd "$repodir/yay" || return 1
#  			sudo -u "$username" git pull --force origin master
#  		}
#  	cd "$repodir/yay" || exit 1
#  	sudo -u "$username" -D "$repodir/yay" \
#  		makepkg --noconfirm -si >/dev/null 2>&1 || return 1
#
# }
# yayinstall || error "Failed to install yay"