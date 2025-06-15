#!/bin/zsh

sudo pacman -S tree

curl -sL https://raw.githubusercontent.com/babarot/afx/HEAD/hack/install | bash
sudo mv ~/bin/afx /usr/bin/afx
afx install

yay -S hyprcursor-git hyprgraphics-git hypridle-git hyprland-git hyprland-protocols-git hyprland-qt-support-git hyprland-qtutils-git hyprlang-git hyprlock-git hyprpaper-git hyprsunset-git hyprutils-git hyprwayland-scanner-git xdg-desktop-portal-hyprland-git
yay -S mako swayosd waybar playerctl

yay -S bob nvm github-cli fd zsh-auto-suggestions zsh-syntax-highlight ranger

nvm install nodejs
bob install nightly

yay -S rust make ninja cmake go python3 python3-pip fzf
yay -S texlive texlive-basic texlive-latexrecommended texlive-latexextra texlive-fontsrecommended texlive-bibtexextra texlive-mathscience

