.PHONY: update-ramiel update-zeruel update-armisael update-leliel update-work update-fold flake-update fmt clean install-nix

help: ## Display this screen
	@echo "Usage: make [target]"
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s \033[0m %s\n", $$1, $$2}'

install-nix:
	curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

update-zeruel: ## Updates nixos server
	sudo -v # Build can take a while and we need root to apply the flake
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.zeruel.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#zeruel

update-armisael: ## Updates Lenovo homelab
	sudo -v
	nix build --extra-experimental-features "nix-command flakes" .#nixosConfigurations.armisael.config.system.build.toplevel
	sudo nixos-rebuild switch --flake .#armisael

build-leliel: ## Updates personal macbook
	 nix build --extra-experimental-features "nix-command flakes"  .#darwinConfigurations.leliel.config.system.build.toplevel -o leliel-flake-output

update-leliel: build-leliel
	sudo darwin-rebuild switch --flake .#leliel

update-work: ## Updates work macbook
	# have to use root zshrc/bashrc as defined by google but nix wants to write to it 😭
	- 	sudo mv /etc/zshrc /etc/zshrc-temp
	- 	sudo mv /etc/bashrc /etc/bashrc-temp
	nix build --impure --extra-experimental-features "nix-command flakes" .#darwinConfigurations.work.config.system.build.toplevel -o work-flake-output
	#./work-flake-output/sw/bin/darwin-rebuild switch --flake .#work
	darwin-rebuild switch --flake .#work
	- sudo mv /etc/zshrc-temp /etc/zshrc
	- sudo mv /etc/bashrc-temp /etc/bashrc

update-remote-work: ## Updates a remote dev workstation
	home-manager switch --impure --flake .#workServer

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
	nix --extra-experimental-features "nix-command" profile wipe-history --older-than 1d
