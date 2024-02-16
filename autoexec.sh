#!/bin/sh
# initial autoexec that creates user account and downloads correct user specific autoexec file
# by Tom Schreiner <tom.schreiner@gmx.de>

installpkg() {
	pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}

pacman --noconfirm --needed -Syu 
installpkg libnewt

name=$(whiptail --inputbox "Welcome!\n First, please enter your preferred username." 10 60 3>&1 1>&2 2>&3 3>&1)
while ! echo "$name" | grep -q "^[a-z_][a-z0-9_-]*$"; do
  name=$(whiptail --nocancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
done
pass1=$(whiptail --nocancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
pass2=$(whiptail --nocancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
while ! [ "$pass1" = "$pass2" ]; do
	unset pass2
	pass1=$(whiptail --nocancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(whiptail --nocancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
done

whiptail --infobox "Adding user \"$name\"..." 10 60
useradd -m -g wheel -s /bin/zsh "$name" >/dev/null 2>&1 ||
usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
export repodir="/home/$name/.local/src"
mkdir -p "$repodir"
chown -R "$name":wheel "$(dirname "$repodir")"
echo "$name:$pass1" | chpasswd
unset pass1 pass2

for x in curl base-devel git ntp zsh; do
	whiptail --title "needed package installation" \
		--infobox "Installing \`$x\`." 10 60
	installpkg "$x"
done

# Make pacman colorful, concurrent downloads and Pacman eye-candy.
grep -q "ILoveCandy" /etc/pacman.conf || sed -i "/#VerbosePkgLists/a ILoveCandy" /etc/pacman.conf
sed -Ei "s/^#(ParallelDownloads).*/\1 = 5/;/^#Color$/s/#//" /etc/pacman.conf

# Use all cores for compilation.
sed -i "s/-j2/-j$(nproc)/;/^#MAKEFLAGS/s/^#//" /etc/makepkg.conf
