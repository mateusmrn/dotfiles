# dotfiles

My personal configuration files and scripts for a Arch Linux + KDE environment.

## Setup

Steps that need to be taken in order to setup the environment. This is not aimed at being
customizable. It's just a list for my personal use so that I have something to follow when I need to
setup a new environment. Will likely turn into a script in the future.

1. Follow the [Arch Linux installation guide](https://wiki.archlinux.org/title/Installation_guide).
   In the "Install essencial packages" section, make sure to also install `networkmanager`,
   `neovim`, `sudo` and `git`
2. Login with root
3. `systemctl enable NetworkManager.service && systemctl start NetworkManager.service`
4. Connect to the Internet with `nmtui`
5. `useradd -m mateus`
6. `passwd mateus`
7. `EDITOR=neovim visudo` and uncomment line for the `wheel` group
8. `usermod -aG wheel mateus`
9. Logout and login as `mateus`
10. `cd`
11. `git clone https://github.com/melosomelo/dotfiles`
12. `sudo pacman -S $(cat dotfiles/packages/official.txt)`
13. [Install `yay`](https://github.com/Jguer/yay?tab=readme-ov-file#installation)
14. `yay -S $(cat dotfiles/packages/aur.txt)`
15. `mkdir -p ~/.config/alacritty`
16. `ln -s ~/dotfiles/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml`
17. run `fish` and then `exit`
18. `rm .config/fish/config.fish`
19. `rm -rf .config/fish/functions`
20. `ln -s ~/dotfiles/fish/config.fish ~/.config/fish/config.fish`
21. `ln -s ~/dotfiles/fish/functions ~/.config/fish`
22. `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`
23. `ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf`
24. `chsh -s /usr/bin/fish`
25. `curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish`
26. `omf install l`
27. `omf install https://github.com/jorgebucaran/nvm.fish`
28.

```
for ext in $(cat dotfiles/code/extensions.txt)
        code --install-extension $ext
end
```

29. `ln -s ~/dotfiles/code/settings.json ~/.config/Code/User/settings.json`
30. `ln -s ~/dotfiles/code/keybindings.json ~/.config/Code/User/keybindings.json`
31. `mkdir -p ~/.ssh`
32. `touch ~/.ssh/config`
33. Configure `ssh` for GitHub authentication via the `config` file
34. Run `gh auth login`
35. `sudo mkdir -p /etc/pacman.d/hooks`
36. `sudo ln -s ~/dotfiles/pacman/hooks/save_package_list.hook /etc/pacman.d/hooks`
37. `sudo systemctl enable docker.service`
38. `sudo systemctl start docker.service`
39. `sudo usermod -aG docker mateus`
40. `sudo systemctl enable cronie && sudo systemctl start cronie`
41. `sudo crontab < ~/dotfiles/cron/base_crontab`
42. `mdkir ~/.config/swhkd`
43. `sudo ln -s ~/dotfiles/swhkd/swhkdrc ~/.config/swhkd/swhkdrc`
44. `sudo chown root:root swhkd`
45. `sudo chmod u+s swhkd`
46. Start swhkd on startup
    [with systemd](https://github.com/waycrate/swhkd/tree/main/contrib/init/systemd)
47. `mkdir ~/.config/mise`
48. `ln -s ~/dotfiles/mise/config.toml ~/.config/mise/config.toml`
49. `sudo ln -s ~/dotfiles/kde/kglobalshortcutsrc ~/.config/kglobalshortcutsrc`
50. `mkdir ~/.config/hypr`
51. `sudo ln -s ~/dotfiles/hypr/hyprland.lua ~/.config/hypr/hyprland.lua`
52. `sudo ln -s ~/dotfiles/hypr/hyprpaper.conf ~/.config/hypr/hyprpaper.conf`
53. `ln -s ~/dotfiles/quickshell ~/.config/quickshell`
54. `ln -s ~/dotfiles/nvim ~/.config/nvim`
55. `mkdir ~/.config/rofi`
56. `ln -s ~/dotfiles/rofi/config.rasi ~/.config/rofi/config.rasi`
57. `sudo ln -s ~/dotfiles/greetd/config.toml /etc/greetd/config.toml`
58. `sudo mkdir -p /etc/systemd/system/greetd.service.d`
59. `sudo ln -s ~/dotfiles/greetd/greetd.service.d/override.conf /etc/systemd/system/greetd.service.d/override.conf`
60. `sudo systemctl daemon-reload`
61. `sudo systemctl disable sddm.service`
62. `sudo systemctl enable greetd.service`
63. Reboot

## Wishlist

- [ ] Configure `qutebrowser`
- [ ] Save web bookmarks independently of web browser
- [ ] Implement a "work mode". This'd be a mode that can be toggled in order to use more work
      optimized software. For instance, use i3 + qutebrowser instead of Chrome + Kwin. It'd be cool
      for times when I want to use my computer more casually or for when other people need to use it
      for some reason.
- [ ] Add some cool themes with color schemes
- [ ] Add some cool screenshots to the README (e.g. fastfetch, maybe make it automatic?)
- [ ] Turn setup section into a script. Would also be cool to have tests for this setup script.
      Maybe via a CI/CD pipeline?
