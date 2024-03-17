.PHONY: update-ramiel
update-ramiel:
	sudo -v # Build can take a while and we need root to apply the flake
	nix build .#nixosConfigurations.ramiel.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#ramiel	

.PHONY: update-leliel
update-leliel:
	sudo -v
	nix build .#darwinConfigurations.leliel.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#leliel

.PHONY: fmt
fmt:
	find . -name "*.nix" | xargs nixfmt

