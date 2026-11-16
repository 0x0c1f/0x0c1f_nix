#!/usr/bin/env bash

# Prepare host files in the requested checkout before evaluation. Example
# hardware and boot settings are not safe defaults for an installed machine.

set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd -P)
die() {
  printf 'prepare: %s\n' "$*" >&2
  exit 1
}
usage() {
  cat <<'USAGE'
Usage: bash scripts/prepare.sh /absolute/new-checkout --state-version VERSION
       [--hardware /etc/nixos/hardware-configuration.nix]
       (--uefi | --bios /dev/disk/by-id/DEVICE | --boot /path/to/boot.nix)

Run on the target NixOS machine. Copies the release to a NEW writable checkout,
copies real hardware settings, writes/copies the selected boot module and runs
nix flake lock. Does not build, activate, partition disks or set passwords.
Existing systems must use their existing system.stateVersion.
USAGE
}

case "${1:-}" in '' | --help | -h)
  usage
  exit 0
  ;;
esac

# Parse every option before checking anything, so a bad combination fails before the copy.
destination=$1
shift
hardware=/etc/nixos/hardware-configuration.nix
boot_mode=
boot_source=
state_version=
while [ "$#" -gt 0 ]; do
  case "$1" in
    --hardware | --state-version | --boot | --bios)
      [ "$#" -ge 2 ] || die "Missing value for $1"
      case "$1" in
        --hardware) hardware=$2 ;;
        --state-version) state_version=$2 ;;
        --boot | --bios)
          [ -z "$boot_mode" ] || die 'Select exactly one boot mode.'
          boot_mode=${1#--}
          boot_source=$2
          ;;
      esac
      shift 2
      ;;
    --uefi)
      [ -z "$boot_mode" ] || die 'Select exactly one boot mode.'
      boot_mode=uefi
      shift
      ;;
    *) die "Unknown argument: $1" ;;
  esac
done

# Refuse anything that could overwrite an existing tree or reuse the release placeholders.
case "$destination" in /*) ;; *) die 'Destination must be an absolute Linux path.' ;; esac
[[ "$state_version" =~ ^[0-9]{2}\.(05|11)$ ]] || die 'Supply --state-version, such as 26.05; preserve the existing value on an installed system.'
[ -n "$boot_mode" ] || die 'Choose --uefi, --bios DEVICE, or --boot FILE.'
command -v nix >/dev/null 2>&1 || die 'Nix is missing. Run this on the target NixOS machine.'
command -v nixos-version >/dev/null 2>&1 || die 'Run preparation on the target NixOS machine.'
command -v realpath >/dev/null 2>&1 || die 'realpath is required.'
[ -f "$hardware" ] || die "Hardware module not found: $hardware"
[ ! -e "$destination" ] || die 'Destination already exists; choose a new directory.'

# Resolve paths first so a relative or symlinked path cannot slip inside the source project.
destination=$(realpath -m -- "$destination")
project_root=$(dirname -- "$source_root")
case "$destination/" in "$source_root/"* | "$project_root/"*) die 'Keep writable checkouts outside the source project.' ;; esac
hardware=$(realpath -- "$hardware")
case "$hardware/" in "$source_root/"*) die 'Supply real target hardware, not the release placeholder.' ;; esac

# Check the boot choice against the running machine; a wrong loader leaves it unbootable.
case "$boot_mode" in
  uefi) [ -d /sys/firmware/efi ] || die 'This machine is not currently booted in UEFI mode. Select the correct boot configuration.' ;;
  bios)
    [[ "$boot_source" =~ ^/dev/[a-zA-Z0-9_./:+-]+$ ]] || die 'BIOS boot device must be an explicit /dev path.'
    [ -b "$boot_source" ] || die "Boot device is not a block device: $boot_source"
    ;;
  boot) [ -f "$boot_source" ] || die "Boot module not found: $boot_source" ;;
esac

# From here files are written, but only in the new checkout; the release copy stays untouched.
trap 'printf "Preparation stopped. Review the checkout at %s; the source snapshot was not modified.\n" "$destination" >&2' ERR
mkdir -p -- "$destination"
tar -C "$source_root" --exclude=.git --exclude=result --exclude='result-*' --exclude=.direnv --exclude=.cache -cf - . |
  tar -C "$destination" -xf -
cp -- "$hardware" "$destination/hosts/desktop/hardware-configuration.nix"
case "$boot_mode" in
  uefi)
    cat >"$destination/hosts/desktop/boot.nix" <<'NIX'
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
NIX
    ;;
  bios)
    printf '{\n  boot.loader.grub.enable = true;\n  boot.loader.grub.device = "%s";\n}\n' "$boot_source" >"$destination/hosts/desktop/boot.nix"
    ;;
  boot) cp -- "$boot_source" "$destination/hosts/desktop/boot.nix" ;;
esac

# Replace the release default with the value supplied for this machine.
sed -i "s/system.stateVersion = \"26.05\";/system.stateVersion = \"$state_version\";/" "$destination/hosts/desktop/settings.nix"

# Lock inside the checkout so its inputs are pinned before the first evaluation.
cd -- "$destination"
nix --extra-experimental-features 'nix-command flakes' flake lock
[ -s flake.lock ] || die 'Nix did not produce a lock file.'
printf 'Prepared and locked: %s\nReview settings, then run: nix flake check --no-write-lock-file\n' "$destination"
