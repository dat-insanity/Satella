#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <package.deb> <report.txt>" >&2
  exit 64
fi

package_path="$1"
report_path="$2"
extract_root="$(mktemp -d)"
trap 'rm -rf "$extract_root"' EXIT

dpkg-deb -x "$package_path" "$extract_root"

architecture="$(dpkg-deb -f "$package_path" Architecture)"
version="$(dpkg-deb -f "$package_path" Version)"
dependencies="$(dpkg-deb -f "$package_path" Depends)"

[[ "$architecture" == "iphoneos-arm64" ]]
[[ "$version" == 2.0.0~beta.* ]]
[[ "$dependencies" == *"mobilesubstrate"* ]]
[[ "$dependencies" == *"preferenceloader"* ]]
[[ "$dependencies" == *"com.opa334.altlist"* ]]

tweak="$extract_root/var/jb/Library/MobileSubstrate/DynamicLibraries/Satella.dylib"
filter="$extract_root/var/jb/Library/MobileSubstrate/DynamicLibraries/Satella.plist"
preferences="$extract_root/var/jb/Library/PreferenceBundles/SatellaPrefs.bundle/SatellaPrefs"
entry="$extract_root/var/jb/Library/PreferenceLoader/Preferences/SatellaPrefs.plist"

[[ -f "$tweak" ]]
[[ -f "$filter" ]]
[[ -f "$preferences" ]]
[[ -f "$entry" ]]
plutil -lint "$filter"
plutil -lint "$entry"

tweak_archs="$(lipo -archs "$tweak")"
preferences_archs="$(lipo -archs "$preferences")"
[[ "$tweak_archs" == "arm64" ]]
[[ " $preferences_archs " == *" arm64 "* ]]
[[ " $preferences_archs " == *" arm64e "* ]]

if otool -L "$tweak" | grep -E '/Library/Frameworks|/usr/lib/libsubstrate' >/dev/null; then
  echo "rootful jailbreak load path found in Satella.dylib" >&2
  exit 1
fi

mkdir -p "$(dirname "$report_path")"
{
  echo "Package: $(basename "$package_path")"
  echo "Version: $version"
  echo "Architecture: $architecture"
  echo "Depends: $dependencies"
  echo "Tweak slices: $tweak_archs"
  echo "Preference slices: $preferences_archs"
  echo
  echo "Package contents:"
  dpkg-deb -c "$package_path"
  echo
  echo "Satella.dylib load commands:"
  otool -L "$tweak"
  echo
  echo "SatellaPrefs load commands:"
  otool -L "$preferences"
} | tee "$report_path"
