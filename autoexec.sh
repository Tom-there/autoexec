#!/bin/sh
# autoexec to setup user and needed packages to set up user environment ON ARCH
# by Tom Schreiner <tom.schreiner@gmx.de>
# CONTENTS
# 0   global:
# 0.1 variables
# 0.2 functions
# 1   init
# 1.1 check if this is arch
# 1.2 welcome the user
# 1.3 update pacman
# 1.4 refreshing arch keyring
# 1.5 installing base packages
# 1.6 NTP sync
# 2   User creation
# 2.1 username
# 2.2 password
# 2.3 user creation process

# 0.1 variables
username="_"
userpass1="_"
userpass2="-"

# 0.2 functions
installpkg(){
  pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
}
error(){
  printf "%s" "$1\n" >&2
  exit 1
}
usererror(){
  error "User aborted."
}

# 1 init
#   Gets the system ready for user creation
# 1.1 check if this is arch
pacman --noconfirm --needed -Sy libnewt || error "Are you sure this is an arch distro and you are logged in as root? If yes, check your internet connection"

# 1.2 welcome
welcome(){
  whiptail --title "Welcome!" --msgbox "This script is designed to install everything you need to be productive!" 10 50
  whiptail --title "Welcome!" --yes-button "Lets go!" --no-button "wait..." -- yesno "Are you ready to set up your user?" 10 50
}
welcome || usererror

# 1.3 update pacman
pacman -Syu

# 1.4 refreshing arch keyring
refreshing(){
  whiptail --title "installing..." --infobox "Refreshing arch keyring" 10 50
  pacman --noconfirm -S archlinux-keyring >/dev/null 2>&1
}
refreshing

# 1.5 installing base packages
for x in curl ca-certificates base-devel git ntp zsh; do
  whiptail --title "installing..." --infobox "Installing $x"
  installpkg "$x"
done

# 1.6 NTP Syncronization
ntpd -q -g >/dev/null

# 2 User creation
#   created the new user and sets it up
# 2.1 ask for username
getusername(){
  username=$(whiptail --inputbox "First, enter your desired username." 10 50 3>&1 1>&2 2>&3 3>&1)
  while ! echo "$username" | grep -q "^[a-z_][a-z0-9_]*$"; do
    username=$(whiptail --nocancel --inputbox "Username not valid.\nPlease enter valid username that matches RegEx: '[a-z_][a-z0-9_]*'" 10 50 3>&1 1>&2 2>&3 3>&1)
  done
}
getusername || usererror

# 2.2 ask for password
getpassword(){
  userpass1=$(whiptail --nocancel --passwordbox "What would you like as your password?" 10 50 3>&1 1>&2 2>&3 3>&1)
  userpass2=$(whiptail --nocancel --passwordbox "Retype password." 10 50 3>&1 1>&2 2>&3 3>&1)
  while ! [ "$userpass1" = "$userpass2" ]; do
    unset userpass2
    userpass1=$(whiptail --nocancel --passwordbox "Passwords did not match. Try again" 10 50 3>&1 1>&2 2>&3 3>&1)
    userpass2=$(whiptail --nocancel --passwordbox "Retype password." 10 50 3>&1 1>&2 2>&3 3>&1)
  done
}
getpassword || usererror

# 2.3 user creation process
usercreation(){
# check if user exists already
  ! { id -q "$username" > /dev/null 2>&1; } || whiptail --title "WARNING" --yes-button "continue" --no-button "abort!" --yesno "The user '$username' already exists?!" 10 50 || usererror
# add user to system
  useradd -m -g wheel -s /bin/zsh "$username" >/dev/null 2>&1 || usermod -a -G wheel "$username" && mkdir -p /home/"$username" && chown "$username":wheel /home/"$username"
  echo "$username:$userpass1" | chpassword
  unset userpass1 userpass2
# edit sudoers file, so that wheel can run sudo
  echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
}
usercreation || error "Error while creating user"