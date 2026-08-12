# Satella 2 Rootless StoreKit Lab

Satella 2 is an authorized StoreKit security-testing laboratory for Dopamine. This branch targets rootless iOS 15.0 through 17.3.1 and uses the Substrate API supplied by ElleKit.

It contains:

- a rootless StoreKit 1 test tweak;
- a PreferenceLoader bundle with an AltList target selector;
- an owned StoreKit 1/StoreKit 2 test application and local StoreKit configuration;
- macOS CI that produces and inspects an installable `iphoneos-arm64` package.

StoreKit 2 testing uses Apple's StoreKit Test environment. Satella does not alter App Store-signed JWS transactions or intercept production receipt-validation endpoints.

## App selection

The Settings selector lists installed user applications through AltList. Satella activates only in applications explicitly selected under Enabled Apps; Apple system applications remain excluded.

Select an application only when you own it or have explicit authorization to test it.

## Build

Requirements:

- macOS with Xcode 15 or newer;
- current Theos with a patched iPhoneOS SDK and Swift support;
- `ldid` and `dpkg`.

Build the rootless package:

```sh
export THEOS="$HOME/theos"
make clean package FINALPACKAGE=1 PACKAGE_VERSION='2.0.0~beta.1'
```

The `.deb` is written to `packages/`. Rootless packaging is always enabled; there is no rootful build.

## StoreKit laboratory app

Open `Lab/SatellaStoreKitLab.xcodeproj`, choose the `SatellaStoreKitLab` scheme, select your development team, and run it on the test device. The shared Run scheme already selects `Products.storekit`.

After installing the Satella package:

1. Open Settings → Satella 2 Lab.
2. Enable the StoreKit 1 lab and select Satella StoreKit Lab under Enabled Apps.
3. Tap Apply, then relaunch the lab app.
4. Use its StoreKit 1 and StoreKit 2 tabs to run the test matrix.

The initial physical-device gate is an iPhone 15 Pro Max on iOS 17.3 with Dopamine 3.0.4. iOS 17.3.1 remains prerelease-compatible but unverified until tested on that exact version.
