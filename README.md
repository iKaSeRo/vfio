# A script to passthrough the GPU and make a Network bridge

## What does the script do?
- When you choose to pass
It copies a modifed mkinitcpio to `/etc/mkinitcpio.conf`, then runs `sudo mkinitcpio -P`,
and updates grub config with `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
Then makes a Network bridge with NetworkManager.

- When you choose to take back the GPU
It does the same as above except, it copies a normal mkinitcpio to `/etc/mkinitcpio.conf`, And instead of making a Network bridge it deletes it.

## How to use the script
+ Make a directory at `~/.config/vfio`
+ Put a normal mkinitcpio at `~/.config/vfio/mkintitcpio.conf`
+ Put a mkinitcpio with vfio changes at `~/.config/vfio/mkintitcpio.vfio`
