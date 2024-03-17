.PHONY: update-ramiel
update-ramiel:
	sudo -v # Build can take a while and we need root to apply the flake
	nix build .#nixosConfigurations.ramiel.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#ramiel	


.PHONY: update-armisael
update-armisael:
	sudo -v
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.armisael.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#armisael

.PHONY: update-leliel
update-leliel:
	sudo -v
	nix build --extra-experimental-features "nix-command flakes" .#darwinConfigurations.leliel.config.system.build.toplevel
	sudo darwin-rebuild switch --flake .#leliel

.PHONY: fmt
fmt:
	find . -name "*.nix" | xargs nixfmt

