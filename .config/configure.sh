#!/bin/zsh

sudo pacman -S tree

curl -sL https://raw.githubusercontent.com/babarot/afx/HEAD/hack/install | bash
sudo mv ~/bin/afx /usr/bin/afx
afx install

yay -S --needed --noconfirm hyprcursor-git hyprgraphics-git hypridle-git hyprland-git hyprland-protocols-git hyprland-qt-support-git hyprland-qtutils-git hyprlang-git hyprlock-git hyprpaper-git hyprsunset-git hyprutils-git hyprwayland-scanner-git xdg-desktop-portal-hyprland-git
yay -S --needed --noconfirm mako swayosd waybar playerctl bob nvm github-cli fd zsh-auto-suggestions zsh-syntax-highlight ranger wl-clipboard

nvm install node
bob install nightly
bob use nightly

yay -S --needed --noconfirm rust make ninja cmake go python3 python3-pip fzf texlive texlive-basic texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-bibtexextra texlive-mathscience
yay -S --needed --noconfirm vivaldi flatpak ranger spotify wofi unzip
yay -S --needed --noconfirm go rust zig
