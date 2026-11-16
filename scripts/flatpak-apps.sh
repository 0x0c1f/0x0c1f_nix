#!/usr/bin/env bash
set -euo pipefail

# Graphical apps live in Flatpak rather than the NixOS package set, so this script is the one
# place they are installed. It never updates them, matching the manual-update policy.
case "${1:-help}" in
  install)
    command -v flatpak >/dev/null 2>&1 || {
      printf 'Flatpak is missing. Apply the NixOS configuration first.\n' >&2
      exit 1
    }

    # The remote is added by a NixOS service; failing here points at that unit instead of
    # letting the script add an unmanaged remote itself.
    if ! flatpak remotes --system --columns=name | grep -Fxq flathub; then
      printf 'The system Flathub remote is missing. Check: systemctl status flatpak-flathub\n' >&2
      exit 1
    fi

    # System installations use the same remote GNOME Software sees. Polkit may
    # request authorization. Do not add --or-update: updates are manual.
    flatpak install --system flathub com.google.Chrome org.videolan.VLC
    printf 'Chrome and VLC are available from GNOME. Select Chrome as the default browser in GNOME Settings.\n'
    ;;
  list)
    command -v flatpak >/dev/null 2>&1 || {
      printf 'Flatpak is missing.\n' >&2
      exit 1
    }
    flatpak list --system --app
    ;;
  help | -h | --help)
    printf '%s\n' 'Usage: bash scripts/flatpak-apps.sh install|list' \
      'Install Google Chrome and VLC from the system Flathub remote, or list installed apps.'
    ;;
  *)
    printf 'Unknown action: %s\n' "$1" >&2
    exit 2
    ;;
esac
