# Flake for running Plasticity-for-Windows on NixOS

> What?

[Plasticity](https://www.plasticity.xyz/) is an up-and-coming CAD modeling software. This repo is a Nix flake that automates the process of getting the Windows version working on NixOS.

> Why not use the Linux version?

In a word, [xNURBS](https://www.plasticity.xyz/#features). If you're looking for a Linux version for Nix, I've been maintaining a standalone [flake for a while](https://github.com/alexandriaptt/plasticity-flake), and there is now also [nixpkgs support](https://search.nixos.org/packages?query=plasticity).

> Why not a shell script?

Reproducibility. With Nix, every dependency can be tracked and linked together via a single repo, nearly guaranteeing that if it worked before, it will keep working.

This flake automatically sets up & configures Wine, fetches the Plasticity MSI installer, does the installation and runs the product, and all with a fairly reproducible layered filesystem.

> Can I use this on Ubuntu / Arch / Fedora?

Probably, though you'll likely need to use [nixGL](https://github.com/nix-community/nixGL). All the machines I have access to run variants of NixOS, so I haven't had the opportunity to test it.

> Do you accept PRs?

Naturally.

## Status

- Confirmed working (GPU accel, rendering, saving and loading, etc)

- If you have configured your kernel for certain kinds of security hardening, it may crash when it tries to spawn the GPU thread. Still debugging.
- Persistence is currently having issues.
- Because of the way Plasticity tracks 'node locking', it may erroneously detect different wine instances on the same machine as a 'different device'. 

## Bonus features

- Convenient DPI control added
- Sets 'dark mode' wine config to better integrate the dialog box with Plasticity and with dark themes in general.

## Quickstart

`nix run github:crabdancing/windows-plasticity-nix`

## How it works

- Nix build & fetch phase:
  - Sets up proton-ge from [nix-gaming](https://github.com/fufexan/nix-gaming) as application-specific wine. This is a `wine` with proton and GloriousEggroll patches, originally intended for the gaming ecosystem.
  - Fetches the Plasticity MSI installer
  - Fetches Plasticity icon
- Nix run phase:
  - Builds semi-isolated Wine environment with [mkwindowsapp](https://github.com/emmanuelrosa/erosanix/tree/master/pkgs/mkwindowsapp).
  - Runs installation wizard during nix run phase (if the app is not already installed)
  - Launches Plasticity.

Note that unlike conventional NixOS applications, this package does not do all of its fetching & install steps during `buildPhase` / `installPhase` / etc proper. Because of the license encumbrance and messy self-extracting executable world of Windows, binary fetching and deployment is often quite limited and awkward, and thus creates friction with Nix's build sandbox. Therefore, to avoid impurities, `mkWindowsApp` essentially creates a separate user-specific pseudo-sandbox environment, with separate wine prefixes distinguished by hashes. This allows one to retain the NixOS benefits while assembling and deploying an installation time 'build product', so to speak. To ensure purity, the application exists in a semi-isolated environment. 


# Disclaimers, Licenses, Credits


This is not an official project, and is not supported or endorsed by [Plasticity upstream](https://www.plasticity.xyz/). All copyrights & trademarks are the property of their respective owners. All code unique to this repo is GNU GPLv3.

This repo contains a couple bits of code/data from elsewhere, including [wine-breeze-dark.reg](https://gist.github.com/Zeinok/ceaf6ff204792dde0ae31e0199d89398) from Zeinok, and `use-theme-none.reg` from bgstack15.
