#!/bin/sh

# Defines the config directory
configdir="${XDG_CONFIG_HOME:-$HOME/.config}/vfio"

# Checks if the config directory exist and if not create it
[ ! -d "$configdir" ] && echo "Directory $configdir does not exist, creating..." && mkdir -p "$configdir"

# Defines some vars
mkvfio="$configdir/mkinitcpio.vfio"
mknorm="$configdir/mkinitcpio.conf"

# Checks if config files exists and if not ask the user to add them
[ ! -f "$mkvfio" ] && echo "File $mkvfio does not exist, please make a mkinitcpio.conf with your vfio changes" && exit 1
[ ! -f "$mknorm" ] && echo "File $mknorm does not exist, please copy your normal /etc/mkinitcpio.conf without vfio changes" && exit 1


# The function that does most of the work
passin(){
    # Copies the mkinitcpio that the user chose to /etc/mkinitcpio.conf
    sudo cp "$1" /etc/mkinitcpio.conf
    # Regenerates the initramfs
	sudo mkinitcpio -P
    # Updates grub config
	sudo grub-mkconfig -o /boot/grub/grub.cfg

    # If the user chose to pass creates a bridge by calling the "mBridge" function
    # And if they chose to take deletes the existing bridge
    [ "$1" = "$mkvfio" ] && mBridge; [ "$1" = "$mknorm" ] && nmcli con delete bridge-br0

    # Asks the user if they want to reboot
    echo "Reboot now? [y/N] " && read -r askReboot
    [ "$askReboot" = y ] || [ "$askReboot" = Y ] && sudo reboot
}

# A function for creating a Network bridge
mBridge(){
    # Defines the network interface change it if you have an interface with another name
    interface="eth0"

    # Creates a bridge with the name "br0"
    nmcli connection add type bridge ifname br0 stp no
    # Makes the interface a slave to the bridge
    nmcli connection add type bridge-slave ifname "$interface" master br0
    # Kills the current connection
    nmcli connection down ethernet-"$interface"
    # Starts the bridge connection
    nmcli connection up bridge-br0
}

# Ask the user if they want to Passthrough or Take back their GPU
echo "[pass]through or [take] your GPU? " && read -r pt

# Takes the user input from the last command
# And depending on it passes or takes back the GPU
case "$pt" in
    [pP][aA][sS][sS] | [pP])
        passin "$mkvfio";;
    [tT][aA][kK][eE] | [tT])
        passin "$mknorm";;
    *)
        echo "Invalid input please type either [pass] or [take]" && exit 1
esac
