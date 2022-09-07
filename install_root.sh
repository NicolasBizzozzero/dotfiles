#!/usr/bin/sh
#
# This specific script needs to be executed as root.
#
# Warning, editing root-level files may fuck-up your install


# sudo
# If this one does not works, login as root (su -) then re-execute it.
cp sudo/sudoers /etc/sudoers && chmod 440 /etc/sudoers && chown root:root /etc/sudoers

# fstab
cp fstab/fstab /etc/fstab && chmod 644 /etc/fstab && chown root:root /etc/fstab

# git
cp gitconfig/gitconfig /etc/gitconfig && chmod 644 /etc/gitconfig && chown root:root /etc/gitconfig

# grub
cp grub/grub /etc/default/grub && chmod 644 /etc/default/grub && chown root:root /etc/default/grub

# pam
cp pam/pam_env.conf /etc/security/



# TODO: 
# /etc/grub.d/ ???
# /etc/hostname
# /etc/hosts
# /etc/leiningen/profiles.clj
# /etc/locale.conf
# /etc/locale.gen
# /etc/mkinitcpio.conf
# /etc/pacman.conf
# /etc/wpa_supplicant/wpa_supplicant-wlp2s0.conf

# Look for "system file backup"


