.PHONY: update-ramiel update-armisael update-leliel update-work update-fold flake-update fmt clean

help: ## Display this screen
	@echo "Usage: make [target]"
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s \033[0m %s\n", $$1, $$2}'


update-ramiel: ## Updates nixos desktop
	sudo -v # Build can take a while and we need root to apply the flake
	nix build .#nixosConfigurations.ramiel.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#ramiel	


update-armisael: ## Updates Lenovo homelab
	sudo -v
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.armisael.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#armisael

update-leliel: ## Updates personal macbook
	sudo -v # darwin rebuild requies sudo but it needs to be run as the current user so we elevate permissions here - avoiding a prompt later on
	nix build --extra-experimental-features "nix-command flakes" .#darwinConfigurations.leliel.config.system.build.toplevel
	darwin-rebuild switch --flake .#leliel

update-work: ## Updates work macbook
	sudo -v
	nix build --extra-experimental-features "nix-command flakes" .#darwinConfigurations.work.config.system.build.toplevel
	darwin-rebuild switch --flake .#work

update-fold: ## Updates Samsung Galaxy fold 5
	nix build --no-link --impure .#androidConfigurations.fold5.activationPackage
	# find where the flake has been built then run the activation script
	$$(nix path-info --impure .#androidConfigurations.fold5.activationPackage)/activate


flake-update: ## Updates flake inputs
	nix --extra-experimental-features "nix-command flakes" flake update

fmt: ## Formats nix, lua and shell files
	find . -name "*.nix" | xargs nixfmt
	find . -name "*.lua" | xargs lua-format -i
	find . -name "*.sh"  | xargs shfmt -w

clean: ## Runs nix GC and store optimization
	sudo -v
	sudo nix-collect-garbage -d --quiet --log-format bar | grep --color 'deleted,' # Clean System profiles
	nix-collect-garbage -d --quiet --log-format bar | grep --color 'deleted,' # Clean user profiles
	nix-store --gc --max-jobs auto --log-format bar | grep --color 'deleted,'
	nix-store --optimise --max-jobs auto --quiet --log-format bar
	nix --extra-experimental-features "nix-command" profile wipe-history --older-than 7d
