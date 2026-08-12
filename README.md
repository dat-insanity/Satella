# Satella 2 — Dopamine rootless port

This branch is a minimal rootless port of the original Satella 2 interface and StoreKit 1 behavior for Dopamine/ElleKit on iOS 15.0 through 17.3.1.

The original Settings layout remains in place: Enable, Receipts, Observer, Sideloaded, Stealth, 0.01 Price, Global Injection, and the AltList Enabled Apps selector. Jinx and manual load-command patching have been replaced by a typed Substrate bridge and Theos' native rootless scheme.

## Allowlist

`Tweak/Satella.plist` is the hard eligibility boundary. Its `Filter/Bundles` array controls both ElleKit injection and the apps displayed by AltList. Runtime policy checks the same installed plist again before enabling StoreKit overrides.

The checked-in placeholder is `emt.paisseon.satellalab`. Replace it only with bundle identifiers for applications you own or are explicitly authorized to test. `Global Injection` means every app in this allowlist; it does not expand eligibility beyond the list.

## Build

Requirements:

- macOS with Xcode 15 or newer;
- current Theos with the patched iPhoneOS 16.5 SDK and Swift support;
- `ldid` and `dpkg`.

```sh
export THEOS="$HOME/theos"
make clean package FINALPACKAGE=1 PACKAGE_VERSION='2.0.0~beta.1'
```

The package is written to `packages/` with architecture `iphoneos-arm64` and installs entirely below `/var/jb`.

## Device test

1. Install the `.deb` through Sileo and perform a userspace reboot.
2. Open Settings → Satella.
3. Enable Satella and either select an allowlisted app under Enabled Apps or enable Global Injection.
4. Tap Apply, then fully relaunch the target app.
5. Test one optional override at a time before combining them.

iOS 17.3.1 support remains provisional until the package is exercised on that exact firmware and target application.
