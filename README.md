# nixos-config

Installing with home-manager:

Install nix:

`sh <(curl -L https://nixos.org/nix/install) --daemon`

Add to ~/.config/nix/nix.conf:

`experimental-features = nix-command flakes`

And then run:

`nix run home-manager/master -- init --switch`

`mkdir ~/projects && cd ~/projects`

`git clone https://github.com/Toomoch/nixos-config.git && cd nixos-config`

`home-manager switch --flake .#user`