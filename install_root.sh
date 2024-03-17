#!/usr/bin/sh
#
# This specific script needs to be executed as root.
#
# Warning, editing root-level files may fuck-up your install


# sudo
# If this one does not works, login as root (su -) then re-execute it.
cp sudo/sudoers /etc/sudoers && chmod 440 /etc/sudoers && chown root:root /etc/sudoers


# /etc
cp etc/hostname /etc/hostname && chmod 644 /etc/hostname && chown root:root /etc/hostname
cp etc/hosts /etc/hosts && chmod 644 /etc/hosts && chown root:root /etc/hosts
cp etc/locale.conf /etc/locale.conf && chmod 644 /etc/locale.conf && chown root:root /etc/locale.conf
cp etc/locale.gen /etc/locale.gen && chmod 644 /etc/locale.gen && chown root:root /etc/locale.gen

# fstab
#cp fstab/fstab /etc/fstab && chmod 644 /etc/fstab && chown root:root /etc/fstab

# git
#cp gitconfig/gitconfig /etc/gitconfig && chmod 644 /etc/gitconfig && chown root:root /etc/gitconfig

# grub
#cp grub/grub /etc/default/grub && chmod 644 /etc/default/grub && chown root:root /etc/default/grub

# leiningen
cp leiningen/profiles.clj /etc/leiningen/profiles.clj && chmod 644 /etc/leiningen/profiles.clj && chown root:root /etc/leiningen/profiles.clj

# mkinitcpio
#cp mkinitcpio/mkinitcpio.conf /etc/mkinitcpio.conf && chmod 644 /etc/mkinitcpio.conf && chown root:root /etc/mkinitcpio.conf

# pacman
cp pacman/pacman.conf /etc/pacman.conf && chmod 644 /etc/pacman.conf && chown root:root /etc/pacman.conf

# pam
cp pam/pam_env.conf /etc/security/pam_env.conf && chmod 644 /etc/security/pam_env.conf && chown root:root /etc/security/pam_env.conf

# wpa_supplicant
cp wpa_supplicant/wpa_supplicant-wlp2s0.conf /etc/wpa_supplicant/wpa_supplicant-wlp2s0.conf && chmod 644 /etc/wpa_supplicant/wpa_supplicant-wlp2s0.conf && chown root:root /etc/wpa_supplicant/wpa_supplicant-wlp2s0.conf
