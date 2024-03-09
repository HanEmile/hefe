# hacknix

A nixos setup for hacking (pentesting).

This has...

- burp pro installed
- the office ca cert installed
- common tools installed

## Installation

- download the minimal NixOS iso
    - https://channels.nixos.org/nixos-22.11/latest-nixos-minimal-x86_64-linux.iso
- create a new VM in Virtualbox
    - call it whatever you like
    - select the previously downloaded iso image
    - set the type to `linux`
    - set the version to `other`
    - give it some RAM
    - give it some CORES
    - enable EFI!
    - give it some storage
- boot the vm, then...
    - `sudo -i`
    - `parted /dev/sda -- mklabel gpt`
    - `parted /dev/sda -- mklabel primary 512MB 100%`
    - `parted /dev/sda -- mklabel ESP fat32 1MB 512MB`
    - `parted /dev/sda -- mklabel set 3 esp on`
    - `pvcreate /dev/sda1`
    - `vgcreate pool /dev/sda1`
    - `lvcreate -L 30GB -n home pool`
    - `mkfs.ext4 /dev/pool/home`
    - `mount /dev/disk/by-label/nixos /mnt`
    - `mkdir -p /mnt/boot`
    - `mount /dev/disk/by-label/boot /mnt/boot`
    - `nixos-generate-config --root /mnt`
    - edit the nixos configuration (this is just preliminary, we're going to use the one in this repo further on)
    - `nixos-install`
        - set a root password
    - `reboot`
- login
    - `git clone https://<git>/<user>/hacknix /etc/nixos`
        - this will probably fail due to missing certs...
    - `sudo nixos-rebuild switch`

