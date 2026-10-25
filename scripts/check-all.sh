#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for example in other-distro-home-manager nixos-home-manager nixos-module; do
  echo "=== checking ${example} ==="
  nix flake check "${repo_root}/${example}"
done
