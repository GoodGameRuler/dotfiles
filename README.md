# README for Udit's Dotfiles
> This is not a symlink based dotfiles. I use this primarily on Arch, and sometimes Debian, Fedora.

Based on the [Git Bare Dotfiles Guide](https://www.atlassian.com/git/tutorials/dotfiles) by Atlassian.

```bash
alias config='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:GoodGameRuler/dotfiles.git $HOME/.dotfiles
config checkout
```
