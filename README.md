# ojuny-test-flakes

Standalone flakes for testing the ojuny module install paths. Each example is
self-contained, pins its own inputs in `flake.lock`, and configures Stylix with
the ojuny everforest-dark-hard theme.

| Example | Path | What it tests |
| --- | --- | --- |
| Home Manager on another distro | `other-distro-home-manager` | `home-manager.lib.homeManagerConfiguration` with `ojuny-desktop.homeManagerModules.default` |
| Home Manager on NixOS | `nixos-home-manager` | `ojuny-desktop.homeManagerModules.default` through `home-manager.users.user` |
| NixOS module | `nixos-module` | `ojuny-desktop.nixosModules.default` |

The settings GUI is intentionally not configured. These flakes test the desktop
module paths, not the full ojuny template or installer.

## Requirements

- Nix with `experimental-features = nix-command flakes`
- `x86_64-linux`
- Network access for the flake inputs and builds

## Check and build

```sh
./scripts/check-all.sh
```

Build each output explicitly:

```sh
nix build ./other-distro-home-manager#homeConfigurations.user.activationPackage
nix build ./nixos-home-manager#nixosConfigurations.ojuny-hm.config.system.build.toplevel
nix build ./nixos-module#nixosConfigurations.ojuny-module.config.system.build.toplevel
```

## Apply

For the standalone Home Manager example on an existing Linux installation:

```sh
home-manager switch --flake ./other-distro-home-manager#user
```

For the NixOS examples:

```sh
sudo nixos-rebuild switch --flake ./nixos-home-manager#ojuny-hm
sudo nixos-rebuild switch --flake ./nixos-module#ojuny-module
```

## Test local upstream changes

The examples use the GitHub inputs by default. Override `ojuny-desktop` (and
optionally `stylix`) to test a local checkout:

```sh
nix build ./nixos-module#nixosConfigurations.ojuny-module.config.system.build.toplevel \
  --override-input ojuny-desktop path:../ojuny-desktop

nix build ./nixos-module#nixosConfigurations.ojuny-module.config.system.build.toplevel \
  --override-input ojuny-desktop path:../ojuny-desktop \
  --override-input stylix path:../stylix
```

Run these from the repository root. Adjust the relative paths if the checkouts
are elsewhere.

## Stylix on NixOS with Home Manager

`nixos-home-manager` configures Stylix at both levels, sets
`stylix.homeManagerIntegration.autoImport = false`, and imports
`stylix.homeModules.stylix` in the Home Manager user. This avoids an infinite
recursion between ojuny's default wallpaper and Stylix's follow-system
inheritance. The standalone Home Manager example imports the Stylix Home
Manager module directly.

## Limitations

- The user is `user` with home `/home/user` and password `test`.
- The root filesystem is the placeholder `/dev/disk/by-label/nixos`.
- Both NixOS examples boot with systemd-boot and a single `/` filesystem.
- The NixOS Home Manager example configures the user environment only. It does
  not add a display manager or a Wayland session for `ojuny-mango`; use it on a
  host that already provides one, or add a session to the example.
- The NixOS module example gets a session from `ojuny-desktop.nixosModules.default`
  but still assumes an existing display manager.
- No `nix-settings-gui`, template setup, installer ISO, `nix run`, VM boot
  test, secrets, or hardware configuration is included.
