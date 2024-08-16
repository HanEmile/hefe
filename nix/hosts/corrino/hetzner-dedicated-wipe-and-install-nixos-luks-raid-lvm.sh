#!/usr/bin/env bash

# Installs NixOS on a Hetzner server, wiping the server.
#
# This is for a specific server configuration; adjust where needed.
#
# Prerequisites:
#   * Update the script wherever FIXME is present
#
# Usage:
#     ssh root@YOUR_SERVERS_IP bash -s < hetzner-dedicated-wipe-and-install-nixos.sh
#
# When the script is done, make sure to boot the server from HD, not rescue mode again.

# Explanations:
#
# * Adapted from https://gist.github.com/nh2/78d1c65e33806e7728622dbe748c2b6a
# * Following largely https://nixos.org/nixos/manual/index.html#sec-installing-from-other-distro.
# * **Important:** We boot in legacy-BIOS mode, not UEFI, because that's what Hetzner uses.
#   * NVMe devices aren't supported for booting (those require EFI boot)
# * We set a custom `configuration.nix` so that we can connect to the machine afterwards,
#   inspired by https://nixos.wiki/wiki/Install_NixOS_on_Hetzner_Online
# * This server has 2 HDDs.
#   We put everything on RAID1.
#   Storage scheme: `partitions -> RAID -> LVM -> ext4`.
# * A root user with empty password is created, so that you can just login
#   as root and press enter when using the Hetzner spider KVM.
#   Of course that empty-password login isn't exposed to the Internet.
#   Change the password afterwards to avoid anyone with physical access
#   being able to login without any authentication.
# * The script reboots at the end.

NIXOS_VERSION="22.11"

echo "Enter New Hostname"
HOSTNAME="corrino"

echo "Enter LUKS Password"
LUKS_PASSWORD="FIXME"

set -eu
set -o pipefail

set -x

# Inspect existing disks
lsblk

# Undo existing setups to allow running the script multiple times to iterate on it.
# We allow these operations to fail for the case the script runs the first time.
set +e
umount /mnt/boot /mnt/dev /mnt/proc /mnt/run /mnt/sys /mnt
vgchange -an
cryptsetup close luks0
rm initrd_ssh_host_ecdsa_key
set -e

# Stop all mdadm arrays that the boot may have activated.
mdadm --stop --scan

# Prevent mdadm from auto-assembling arrays.
# Otherwise, as soon as we create the partition tables below, it will try to
# re-assemple a previous RAID if any remaining RAID signatures are present,
# before we even get the chance to wipe them.
# From:
#     https://unix.stackexchange.com/questions/166688/prevent-debian-from-auto-assembling-raid-at-boot/504035#504035
# We use `>` because the file may already contain some detected RAID arrays,
# which would take precedence over our `<ignore>`.
echo 'AUTO -all
ARRAY <ignore> UUID=00000000:00000000:00000000:00000000' > /etc/mdadm/mdadm.conf

# Create partition tables (--script to not ask)
parted --script /dev/nvme0n1 mklabel gpt
parted --script /dev/nvme1n1 mklabel gpt

# Create partitions (--script to not ask)
#
# We create the 1MB BIOS boot partition at the front.
#
# Note we use "MB" instead of "MiB" because otherwise `--align optimal` has no effect;
# as per documentation https://www.gnu.org/software/parted/manual/html_node/unit.html#unit:
# > Note that as of parted-2.4, when you specify start and/or end values using IEC
# > binary units like "MiB", "GiB", "TiB", etc., parted treats those values as exact
#
# Note: When using `mkpart` on GPT, as per
#   https://www.gnu.org/software/parted/manual/html_node/mkpart.html#mkpart
# the first argument to `mkpart` is not a `part-type`, but the GPT partition name:
#   ... part-type is one of 'primary', 'extended' or 'logical', and may be specified only with 'msdos' or 'dvh' partition tables.
#   A name must be specified for a 'gpt' partition table.
# GPT partition names are limited to 36 UTF-16 chars, see https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_entries_(LBA_2-33).
parted --script --align optimal /dev/nvme0n1 -- mklabel gpt mkpart 'bios' 1MB 2MB set 1 bios_grub on mkpart 'boot' 2MB 1000MB mkpart 'root' 1000MB '100%'
parted --script --align optimal /dev/nvme1n1 -- mklabel gpt mkpart 'bios' 1MB 2MB set 1 bios_grub on mkpart 'boot' 2MB 1000MB mkpart 'root' 1000MB '100%'

# Relaod partitions
partprobe

# Wait for all devices to exist
udevadm settle --timeout=5 --exit-if-exists=/dev/nvme0n1p1
udevadm settle --timeout=5 --exit-if-exists=/dev/nvme0n1p2
udevadm settle --timeout=5 --exit-if-exists=/dev/nvme0n1p3

udevadm settle --timeout=5 --exit-if-exists=/dev/nvme1n1p1
udevadm settle --timeout=5 --exit-if-exists=/dev/nvme1n1p2
udevadm settle --timeout=5 --exit-if-exists=/dev/nvme1n1p3

# Wipe any previous RAID signatures
mdadm --zero-superblock --force /dev/nvme0n1p2
mdadm --zero-superblock --force /dev/nvme0n1p3
mdadm --zero-superblock --force /dev/nvme1n1p2
mdadm --zero-superblock --force /dev/nvme1n1p3

# Create RAIDs
# Note that during creating and boot-time assembly, mdadm cares about the
# host name, and the existence and contents of `mdadm.conf`!
# This also affects the names appearing in /dev/md/ being different
# before and after reboot in general (but we take extra care here
# to pass explicit names, and set HOMEHOST for the rebooting system further
# down, so that the names appear the same).
# Almost all details of this are explained in
#   https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14
# and the followup comments by Doug Ledford.
#mdadm --create --run --verbose /dev/md0 --level=1 --raid-devices=2 --homehost=lxc11 --name=root0 /dev/nvme0n1p2 /dev/nvme1n1p2
mdadm --create --run --verbose /dev/md0 --level=1 --raid-devices=2 --homehost=$HOSTNAME --name=md0 /dev/nvme0n1p2 /dev/nvme1n1p2
mdadm --create --run --verbose /dev/md1 --level=1 --raid-devices=2 --homehost=$HOSTNAME --name=md1 /dev/nvme0n1p3 /dev/nvme1n1p3

# Assembling the RAID can result in auto-activation of previously-existing LVM
# groups, preventing the RAID block device wiping below with
# `Device or resource busy`. So disable all VGs first.
vgchange -an

# Wipe filesystem signatures that might be on the RAID from some
# possibly existing older use of the disks (RAID creation does not do that).
# See https://serverfault.com/questions/911370/why-does-mdadm-zero-superblock-preserve-file-system-information
wipefs -a /dev/md0
wipefs -a /dev/md1

# Disable RAID recovery. We don't want this to slow down machine provisioning
# in the rescue mode. It can run in normal operation after reboot.
echo 0 > /proc/sys/dev/raid/speed_limit_max

# LUKS
echo "$LUKS_PASSWORD" | cryptsetup luksFormat --type luks2 -h sha512 /dev/md1
echo "$LUKS_PASSWORD" | cryptsetup luksOpen /dev/md1 luks0

# LVM
# PVs
pvcreate /dev/mapper/luks0
#pvcreate /dev/md0

# VGs
#vgcreate vg0 /dev/md0
vgcreate vg0 /dev/mapper/luks0

# LVs (--yes to automatically wipe detected file system signatures)
lvcreate --yes --extents 95%FREE -n root vg0  # 5% slack space

# Filesystems (-F to not ask on preexisting FS)
mkfs.ext4 -F -L boot /dev/md0
mkfs.ext4 -F -L root /dev/vg0/root

# Creating file systems changes their UUIDs.
# Trigger udev so that the entries in /dev/disk/by-uuid get refreshed.
# `nixos-generate-config` depends on those being up-to-date.
# See https://github.com/NixOS/nixpkgs/issues/62444
udevadm trigger

# Wait for FS labels to appear
udevadm settle --timeout=5 --exit-if-exists=/dev/disk/by-label/boot
udevadm settle --timeout=5 --exit-if-exists=/dev/disk/by-label/root

# NixOS pre-installation mounts

# Mount target root partition
mount /dev/disk/by-label/root /mnt
mkdir /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Installing nix

# Installing nix requires `sudo`; the Hetzner rescue mode doesn't have it.
apt-get install -y sudo

# Allow installing nix as root, see
#   https://github.com/NixOS/nix/issues/936#issuecomment-475795730
mkdir -p /etc/nix
echo "build-users-group =" > /etc/nix/nix.conf

curl -L https://nixos.org/nix/install | sh
set +u +x # sourcing this may refer to unset variables that we have no control over
. $HOME/.nix-profile/etc/profile.d/nix.sh
set -u -x

# FIXME Keep in sync with `system.stateVersion` set below!
nix-channel --add https://nixos.org/channels/nixos-$NIXOS_VERSION nixpkgs
nix-channel --update

# Getting NixOS installation tools
nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"

nixos-generate-config --root /mnt

# Find the name of the network interface that connects us to the Internet.
# Inspired by https://unix.stackexchange.com/questions/14961/how-to-find-out-which-interface-am-i-using-for-connecting-to-the-internet/302613#302613
RESCUE_INTERFACE=$(ip route get 8.8.8.8 | grep -Po '(?<=dev )(\S+)')

# Find what its name will be under NixOS, which uses stable interface names.
# See https://major.io/2015/08/21/understanding-systemds-predictable-network-device-names/#comment-545626
# NICs for most Hetzner servers are not onboard, which is why we use
# `ID_NET_NAME_PATH`otherwise it would be `ID_NET_NAME_ONBOARD`.
INTERFACE_DEVICE_PATH=$(udevadm info -e | grep -Po "(?<=^P: )(.*${RESCUE_INTERFACE})")
UDEVADM_PROPERTIES_FOR_INTERFACE=$(udevadm info --query=property "--path=$INTERFACE_DEVICE_PATH")
NIXOS_INTERFACE=$(echo "$UDEVADM_PROPERTIES_FOR_INTERFACE" | grep -o -E 'ID_NET_NAME_PATH=\w+' | cut -d= -f2)
echo "Determined NIXOS_INTERFACE as '$NIXOS_INTERFACE'"
# DOESNT WORK on PX server there it was eno1

IP_V4=$(ip route get 8.8.8.8 | grep -Po '(?<=src )(\S+)')
echo "Determined IP_V4 as $IP_V4"

# Determine Internet IPv6 by checking route, and using ::1
# (because Hetzner rescue mode uses ::2 by default).
# The `ip -6 route get` output on Hetzner looks like:
#   # ip -6 route get 2001:4860:4860:0:0:0:0:8888
#   2001:4860:4860::8888 via fe80::1 dev eth0 src 2a01:4f8:151:62aa::2 metric 1024  pref medium
IP_V6="$(ip route get 2001:4860:4860:0:0:0:0:8888 | head -1 | cut -d' ' -f7 | cut -d: -f1-4)::1"
echo "Determined IP_V6 as $IP_V6"


# From https://stackoverflow.com/questions/1204629/how-do-i-get-the-default-gateway-in-linux-given-the-destination/15973156#15973156
read _ _ DEFAULT_GATEWAY _ < <(ip route list match 0/0); echo "$DEFAULT_GATEWAY"
echo "Determined DEFAULT_GATEWAY as $DEFAULT_GATEWAY"

# Generate `configuration.nix`. Note that we splice in shell variables.
cat > /mnt/etc/nixos/configuration.nix <<EOF
{ config, pkgs, lib, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  # Use GRUB2 as the boot loader.
  # We don't use systemd-boot because Hetzner uses BIOS legacy boot.
  boot.loader.systemd-boot.enable = false;
  
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    version = 2;
    enableCryptodisk = true;
    device = "nodev";
    devices = [ "/dev/nvme0n1" "/dev/nvme1n1"];
  };
  networking.hostName = "$HOSTNAME";
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.initrd.availableKernelModules = [ "cryptd" "aesni_intel" "igb" ];#"FIXME Your network driver" ];
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      
      # ssh port during boot for luks decryption
      port = 2222;
      authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
      hostKeys = [ "/initrd_ssh_host_ecdsa_key" ];
    };
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
  boot.kernelParams = [ "ip=$IP_V4::$DEFAULT_GATEWAY:255.255.255.192:$HOSTNAME:$NIXOS_INTERFACE:off:8.8.8.8:8.8.4.4:" ];
  boot.loader.supportsInitrdSecrets = true;
  boot.initrd.luks.forceLuksSupportInInitrd = true;
  boot.initrd.luks.devices = {
    root = {
      preLVM = true;
      device = "/dev/md1";
      allowDiscards = true;
    };
  };
                  
  boot.initrd.secrets = {
    "/initrd_ssh_host_ecdsa_key" = "/initrd_ssh_host_ecdsa_key";
  };
  # The mdadm RAID1s were created with 'mdadm --create ... --homehost=hetzner',
  # but the hostname for each machine may be different, and mdadm's HOMEHOST
  # setting defaults to '<system>' (using the system hostname).
  # This results mdadm considering such disks as "foreign" as opposed to
  # "local", and showing them as e.g. '/dev/md/hetzner:root0'
  # instead of '/dev/md/root0'.
  # This is mdadm's protection against accidentally putting a RAID disk
  # into the wrong machine and corrupting data by accidental sync, see
  # https://bugzilla.redhat.com/show_bug.cgi?id=606481#c14 and onward.
  # We do not worry about plugging disks into the wrong machine because
  # we will never exchange disks between machines, so we tell mdadm to
  # ignore the homehost entirely.
  environment.etc."mdadm.conf".text = ''
    HOMEHOST <ignore>
  '';
  # The RAIDs are assembled in stage1, so we need to make the config
  # available there.
  boot.initrd.services.swraid.mdadmConf = config.environment.etc."mdadm.conf".text;
  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."$NIXOS_INTERFACE".ipv4.addresses = [
    {
      address = "$IP_V4";
      
      # FIXME Lookup for right netmask prefix length within rescu system
      prefixLength = 26;
    }
  ];
  networking.interfaces."$NIXOS_INTERFACE".ipv6.addresses = [
    {
      address = "$IP_V6";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = "$DEFAULT_GATEWAY";
  networking.defaultGateway6 = { address = "fe80::1"; interface = "$NIXOS_INTERFACE"; };
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  # Initial empty root password for easy login:
  users.users.root.initialHashedPassword = "";
  services.openssh.permitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    # FIXME Replace this by your SSH pubkey!
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZi43zHEsoWaQomLGaftPE5k0RqVrZyiTtGqZlpWsew"
  ];
  services.openssh.enable = true;
  
  # FIXME
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "$NIXOS_VERSION"; # Did you read the comment?
}
EOF

ssh-keygen -t ecdsa -N "" -f initrd_ssh_host_ecdsa_key;
cp initrd_ssh_host_ecdsa_key /mnt/initrd_ssh_host_ecdsa_key;

# Install NixOS
PATH="$PATH" `which nixos-install` --no-root-passwd --root /mnt --max-jobs 40

umount /mnt/boot
umount /mnt

echo "DONE"
