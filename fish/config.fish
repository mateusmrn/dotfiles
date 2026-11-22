# abbreviations
abbr -a gs git status
abbr -a gd git diff
abbr -a ga git add
abbr -a gp git push
abbr -a gpo git push origin
abbr -a gpom git push origin main
abbr -a gpl git pull 
abbr -a gc git commit
abbr -a gcm git commit -m \"
abbr -a gcam git commit -a -m \"
abbr -a gco git checkout
abbr -a gl git log

abbr -a ngmo nest g mo
abbr -a ngco nest g co
abbr -a ngpr nest g pr

abbr -a lz lazydocker

abbr -a tls tmux ls
abbr -a ta tmux a

abbr -a npmc npm run commit

abbr -a hr hyprctl

abbr -a czc cz commit

abbr -a cl claude

# aliases
alias v nvim

# global variables
set -g fish_greeting
set -gx DOTFILES $HOME/dotfiles
set -gx EDITOR nvim
set -gx NVM_INITIALIZED false
# set -gx QT_STYLE_OVERRIDE breeze
set -gx ANDROID_HOME /home/mateus/Android/Sdk

fish_add_path $ANDROID_HOME/emulator
fish_add_path $ANDROID_HOME/platform-tools
fish_add_path $HOME/.local/bin

# start X at login
if status is-login
  if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
	  #exec startx -- -keeptty
  end
end

