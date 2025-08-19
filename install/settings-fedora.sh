#!/bin/bash

# GNOME configuration for Fedora dotfiles

# Keyboard settings
gsettings reset org.gnome.desktop.input-sources xkb-options
gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
gsettings set org.gnome.desktop.peripherals.keyboard repeat true
gsettings set org.gnome.desktop.peripherals.keyboard delay 300
gsettings set org.gnome.desktop.peripherals.keyboard repeat-interval 30

# Trackpad settings (macOS-like)
# gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
# gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true
# gsettings set org.gnome.desktop.peripherals.touchpad two-finger-scrolling-enabled true
# gsettings set org.gnome.desktop.peripherals.touchpad click-method 'fingers'
# gsettings set org.gnome.desktop.peripherals.touchpad speed 0.3
# gsettings set org.gnome.desktop.peripherals.mouse accel-profile 'adaptive'
# gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Super>Tab']"

