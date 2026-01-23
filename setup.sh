#!/bin/bash

# Dotfiles setup script
# Run this on a new Mac after cloning the repo

DOTFILES_DIR="$HOME/.dotfiles"

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

# Spaceship
ln -sf "$DOTFILES_DIR/spaceship/spaceshiprc.zsh" ~/.spaceshiprc.zsh

echo "Dotfiles linked!"
