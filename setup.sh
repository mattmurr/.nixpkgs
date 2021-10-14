#!/usr/bin/env bash

echo "Installing Nix"
curl -L https://nixos.org/nix/install | sh -s -- --darwin-use-unencrypted-nix-store-volume
echo "Sourcing $HOME/.nix-profile/etc/profile.d/nix.sh"
. $HOME/.nix-profile/etc/profile.d/nix.sh

echo "Installing nix-darwin"
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
rm -rf ./result

echo "Installing homebrew"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
