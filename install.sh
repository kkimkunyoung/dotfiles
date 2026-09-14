#!/bin/bash

set -e

DOTFILES="$HOME/.dotfiles"

files=(
    .zshrc
    .zprofile
    .zshenv
    .vimrc
    .tmux.conf
    .gitconfig
)

for file in "${files[@]}"; do
    target="$HOME/$file"

    if [[ -L "$target" ]]; then
        rm "$target"
    elif [[ -e "$target" ]]; then
        mv "$target" "$target.backup"
    fi

    ln -s "$DOTFILES/$file" "$target"
done

echo "Dotfiles installed."
