dotfiles
========

This is the base set of config files, or "dotfiles", used on MakerSquare lab machines. This repo is formatted to work correctly with the [homesick gem](https://github.com/technicalpickles/homesick).

## I want!

To install these dotfiles on your own machine, just run the following at the console:

```console
gem install homesick
homesick clone https://github.com/makersquare/dotfiles.git
homesick symlink dotfiles
```

## Upgrading

To upgrade your dotfiles, simply run the following commands:

```console
homesick pull dotfiles
homesick symlink dotfiles
```

If you see an error message like this when you run the above:

```text
Cannot pull with rebase: You have unstaged changes.
Please commit or stash them.
```

...you'll just need to run the following instead:

```console
cd ~/.homesick/repos/dotfiles
git add .
git stash save
homesick pull dotfiles
homesick symlink dotfiles
git stash pop
```
