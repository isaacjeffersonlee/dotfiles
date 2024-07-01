fpath=( "$HOME/.config/zsh/" $fpath )
# Current Course
export MY_VENVS_PATH="$HOME/.virtualenvs"
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>> ALIAS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
alias q="rlwrap -a -r ~/q/l64/q"
alias dev="distrobox enter --root dev"
alias tex="distrobox enter --root latex-arch"
alias record="simplescreenrecorder"
alias ipython="ipython --TerminalInteractiveShell.editing_mode=vi --TerminalInteractiveShell.emacs_bindings_in_vi_insert_mode=False"
alias tmux="tmux -u"
alias jl="jupyter-lab"
# Copy with progress
alias pcp="sudo rsync -r --progress"
alias v='nvim'
# alias r="ranger"
alias ls="ls --color=auto"
# alias cleanup="(set -x; sudo pacman -Rs $(pacman -Qdtq))"
alias ll="ls -alG"
alias lg="lazygit"
# youtube-dl a.k.a yt-dlp
alias yt-aac="yt-dlp --extract-audio --audio-format aac"
alias yt-best="yt-dlp --extract-audio --audio-format best"
alias yt-flac="yt-dlp --extract-audio --audio-format flac"
alias yt-m4a="yt-dlp --extract-audio --audio-format m4a"
alias yt-mp3="yt-dlp --extract-audio --audio-format mp3"
alias yt-opus="yt-dlp --extract-audio --audio-format opus"
alias yt-wav="yt-dlp --extract-audio --audio-format wav"
alias yt-best="yt-dlp -f bestvideo+bestaudio"
# Weather
alias weather_map="kitty icat https://v3.wttr.in/London.png"
alias weather_report="kitty icat https://v2d.wttr.in/London.png"
# Dev
alias jn="jupyter notebook"
#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>> AUTOCOMPLETE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
autoload -Uz compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
# Use vim keys in tab complete menu:
bindkey -M menuselect '^h' vi-backward-char
bindkey -M menuselect '^k' vi-up-line-or-history
bindkey -M menuselect '^l' vi-forward-char
bindkey -M menuselect '^j' vi-down-line-or-history
_comp_options+=(globdots)		# Include hidden files.
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^p" up-line-or-beginning-search # Up
bindkey "^n" down-line-or-beginning-search # Down
bindkey "^k" up-line-or-beginning-search # Up
bindkey "^j" down-line-or-beginning-search # Down

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>> CUSTOM FUNCTIONS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
pdf-wc() {
    pdftotext $1 - | tr -d '.' | wc -w
}
# Kill
wkill() {
  kill -KILL $(pgrep $1)
}
# Autojump function
# https://github.com/wting/autojump
# source "$HOME/.config/zsh/plugins/autojump/autojump.zsh" >> Moved to .zprofile
# Overiding default autojump j wrapper with our own function 
j() {
    cd $(autojump $1) && ls
}
r() {
  if [ "$1" != "" ]; then
    if [ -d "$1" ]; then
      ranger "$1"
    elif [ -f "$1" ]; then
      ranger --selectfile="$1"
    else
      out="$(autojump $1)"
      if [ -d "$out" ]; then
        ranger "$out"
      else
        ranger --selectfile="$out"
      fi
    fi
  else
    source ranger  # Remembers current filepath on exit
  fi
	return $?
}

# PACKAGE MANAGER FUNCTIONS
#
# Arch -----------------------------------------------------------------------
pu() {
  sudo pacman -Syu && yay -Syu
}
pf() { 
  PACKAGES=$(pacman -Slq | fzf -m --preview 'cat <(pacman -Si {1})' --margin=10% --border=sharp | tr '\n' ' ')
  if [ "$PACKAGES" != '' ]; then
    # Note: We use $(echo ...) so that pacman doesn't interpret $PACKAGES as all one string
    sudo pacman -S --noconfirm $(echo "$PACKAGES")
  fi
}
pr() { 
  PACKAGES=($(pacman -Qe | fzf -m --margin=10% --border=sharp | awk '{print $1}' | tr '\n' ' '))
  for package in "${PACKAGES[@]}"; do
    sudo pacman -Rns "$package"
  done
}
yf() { 
  PACKAGES=$(yay -Slq | fzf -m --preview 'cat <(yay -Si {1})' --margin=10% --border=sharp | tr '\n' ' ')
  if [ "$PACKAGES" != '' ]; then
  # Note: We use $(echo ...) so that pacman doesn't interpret $PACKAGES as all one string
    yay -S --noconfirm $(echo "$PACKAGES")
  fi
}
yr() { 
  PACKAGES=($(yay -Qe | fzf -m --margin=20% --border=sharp | awk '{print $1}' | tr '\n' ' '))
  for package in "${PACKAGES[@]}"; do
    yay -Rns "$package"
  done
}

#
# Void -----------------------------------------------------------------------
#
#pf() { xbps-query -Rs '*' | awk '{print $2}' | fzf --prompt="Select package(s) to install: " --multi --margin 10% --padding 10% --border | xargs -ro sudo xbps-install -Sy }
#pr() { xbps-query -m | fzf --prompt="Select package(s) to remove: " --multi --margin 10% --padding 10% --border | xargs -ro sudo xbps-remove -Ro }
#pu() { sudo xbps-install -Su }
#
# Debian --------------------------------------------------------------------- 
#
# APT
#
# Install packages (with apt)
# pf() {
#     package="$(apt-cache pkgnames | fzf --multi --cycle \
#     --preview "apt-cache show {1}" --preview-window=:65%:wrap)" && \
#     sudo apt install -y $package && echo $package >> $HOME/dotfiles/Scripts/.scripts/Install/Ubuntu/ubuntu_apps.txt
# }

# Install packages (with nala)
# pf() {
    # package="$(apt-cache pkgnames | fzf --multi --cycle \
    # --preview "apt-cache show {1}" --preview-window=:65%:wrap)" && \
    # sudo nala install -y $package && echo $package >> $HOME/dotfiles/Scripts/.scripts/Install/Ubuntu/ubuntu_apps.txt
# }
# Update packages (with nala)
# pu() {
    # sudo nala update
# }
# Update packages (with apt)
# pu() {
#     sudo apt update && sudo apt upgrade
# }
# List packages
# pl() {
    # comm -13 \
      # <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort) \
      # <(comm -23 \
        # <(dpkg-query -W -f='${Package}\n' | sed 1d | sort) \
        # <(apt-mark showauto | sort) )
# }
# Remove packages (with nala)
# pr() {
    # comm -13 \
      # <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort) \
      # <(comm -23 \
        # <(dpkg-query -W -f='${Package}\n' | sed 1d | sort) \
        # <(apt-mark showauto | sort) ) \
    # | fzf --multi --cycle \
    # --preview "apt-cache show {1}" --preview-window=:65%:wrap \
    # | xargs -ro sudo nala remove -y
# }
# Remove packages (with apt)
# pr() {
#     comm -13 \
#       <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort) \
#       <(comm -23 \
#         <(dpkg-query -W -f='${Package}\n' | sed 1d | sort) \
#         <(apt-mark showauto | sort) ) \
#     | fzf --multi --cycle \
#     --preview "apt-cache show {1}" --preview-window=:65%:wrap \
#     | xargs -ro sudo apt remove -y
# }
# PYTHON VIRTUAL ENVIRONMENT MANAGEMENT
# new virtual environment
ven() {
    python3 -m venv "$MY_VENVS_PATH/$1"
}
# auto activate python virtual env
# auto_vea() {
#     if [[ ! -z $VIRTUAL_ENV ]]; then
#         deactivate # > /dev/null 2>&1
#     fi
#     if git status &>/dev/null; then
#         PROJ_ROOT=$(dirname $(git rev-parse --git-dir))
#         if [[ -f "$PROJ_ROOT/.pyvenv" ]]; then
#             ENV=$(cat "$PROJ_ROOT/.pyvenv")
#             source "$MY_VENVS_PATH/$ENV/bin/activate" # > /dev/null 2>&1
#         fi
#     fi
# }
# autoload -U add-zsh-hook
# add-zsh-hook chpwd auto_vea
# list and activate a virtual environment
vea() {
    select env in $(ls "$MY_VENVS_PATH")
    do 
        source "$MY_VENVS_PATH/$env/bin/activate"
       break
    done
}
ved() {
    deactivate
}
# NOTES WITH NVIM
note() {
    FILE_NAME="$HOME/Documents/Notes/Brain/$(date +"%d%m%y")-"$1".md"
    # touch $FILE_NAME && \
    # echo \# "$1"\n\#\# Date: (date +"%d-%m-%y") >> $FILE_NAME && \
    nvim $FILE_NAME
}
todo() {
    FILE_NAME="$HOME/Documents/Notes/Brain/$(date +"%d%m%y")-"$1".todo.md"
    # touch $FILE_NAME && \
    # echo \# "$1"\n\#\# Date: (date +"%d-%m-%y") >> $FILE_NAME && \
    nvim $FILE_NAME
}
journal() {
    FILE_NAME="$HOME/Documents/Journal/$(date +"%d%m%y")-"$1"-journal.md"
    # touch $FILE_NAME && \
    # echo \# "$1"\n\#\# Date: (date +"%d-%m-%y") >> $FILE_NAME && \
    nvim $FILE_NAME
}
# SHELL HISTORY FUNCTIONS
fh() {
  eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}
# Pipe the last command in history to less so we can scroll through it
less_previous() {
    LAST_CMD="$(history -1 | cut -c 8-)"
    eval $LAST_CMD | less
}
# Monitor the progress of a copy, useful for big copies
big_cp(){
    rsync -a --progress $1 $2
}
rgpdf() {
    # Ripgrep-all lines from given file, then with sed we delete all colons so page numbers are n and not n: thenwe open the
    # given page with zathura, our pdf reader
        rga ".*" $1 | sed 's/://g' | fzf -e --preview="pdftotext $1 -f {2} -l {2} -" | cut -d ' ' -f 2 | xargs -ro zathura $1 -P
}
rgdir() {
    # Search entire directory
    FILE_INFO=$(rga ".*" * | sed 's/:/ /g' | fzf -e --preview="pdftotext {1} -f {3} -l {3} -")
    FILE_NAME=$(echo $FILE_INFO | cut -d ' ' -f 1)
    PAGE_NUM=$(echo $FILE_INFO | cut -d ' ' -f 3)
    # Don't open zathura if $PAGE_NUM is empty, i.e we exit fzf without choosing an option
    [[ ! -z $PAGE_NUM ]] && zathura $FILE_NAME -P $PAGE_NUM
}
rgauto(){
    # Recursively find all pdf files then ripgrep the selected one
    # rgpdf $(swaymsg -t get_tree | grep .pdf | cut -d '"' -f 4 | xargs -ro locate | fzf)
    rgpdf $(fdfind -e pdf | fzf)
}

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HISTORY <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=$HOME/.zsh_history

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> PLUGINS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
source "$HOME/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
source "$HOME/.config/zsh/plugins/zsh-autopair/autopair.zsh" && autopair-init
source "$HOME/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" && ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=blue,bold,underline"
source "$HOME/.config/zsh/plugins/zsh-colored-man-pages/colored-man-pages.plugin.zsh"
source "$HOME/.config/zsh/plugins/zsh-vim-mode/zsh-vim-mode.plugin.zsh"
source "$HOME/.config/zsh/plugins/autojump/autojump.zsh"
# source "$HOME/.config/zsh/plugins/powerlevel10k/powerlevel10k.zsh-theme"

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>> COLORS <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
autoload -Uz colors && colors
zle_highlight=('paste:none')
export MODE_CURSOR_VIINS="blinking bar"
export MODE_CURSOR_REPLACE="$MODE_CURSOR_VIINS #ff0000"
export MODE_CURSOR_VICMD="block"
export MODE_CURSOR_SEARCH="#ff00ff steady underline"
export MODE_CURSOR_VISUAL="$MODE_CURSOR_VICMD steady bar"
export MODE_CURSOR_VLINE="$MODE_CURSOR_VISUAL #00ffff"

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>> PROMPT <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
setopt PROMPT_SUBST
# Disable default python venv prompt so we can set manually
export VIRTUAL_ENV_DISABLE_PROMPT=1
parse_env() {
    if [ -z "$VIRTUAL_ENV" ]; then # do nothing if not in a venv
    else
        echo " %F{green} $(basename $VIRTUAL_ENV)%f"
    fi
}
parse_git_branch() {
    BRANCH_NAME="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    if [ -z "$BRANCH_NAME" ]; then # do nothing if not in a venv
    else # Echo branch glyph and branch name
        # echo " \uE0A0 $BRANCH_NAME" # Doesn't work for some fonts
        echo "  $BRANCH_NAME"
    fi
}
parse_toolbox_name() {
  # Taken from powerlevel10k prompt
  if [[ -f /run/.containerenv && -r /run/.containerenv ]]; then
    local name=(${(Q)${${(@M)${(f)"$(</run/.containerenv)"}:#name=*}#name=}})
    [[ ${#name} -eq 1 && -n ${name[1]} ]] || return 0
    typeset -g TOOLBOX_NAME=${name[1]}
  elif [[ -n $DISTROBOX_ENTER_PATH ]]; then
    local name=${(%):-%m}
    # $NAME can be empty, see https://github.com/romkatv/powerlevel10k/pull/1916.
    if [[ -n $name && $name == $NAME* ]]; then
      typeset -g TOOLBOX_NAME=$name
    fi
  fi
  if [[ -z "$TOOLBOX_NAME" ]]; then  # do nothing if not in a toolbox
  else
      echo " %F{yellow} $TOOLBOX_NAME%f"
  fi
}
# Check length of pwd and print a newline character if too long
check_linebreak() {
    pwd_len=${#PWD} # find length of current pwd
    if [[ $pwd_len > 30 ]]; then
        print -n "\n "
    fi
}
# Prompt functions
minimal_prompt(){
    BRANCH_NAME="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/')"
    echo " %B%9c%b%F{cyan}$(parse_git_branch)%f%F{blue}$(parse_env)%f$(parse_toolbox_name)$(check_linebreak)%F{white}  "
}

powerline_prompt(){
    # Colors
    pwd_bg_color="#296873"
    pwd_fg_color="#ffffff"
    git_bg_color="#6FaEaF"
    git_fg_color="#000000"
    pyvenv_fg_color="#364f6b"
    pyvenv_bg_color="#fff1ac"
    # Parse git branch
    BRANCH_NAME="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/')"
    echo "%K{$pwd_bg_color}%F{$pwd_fg_color} %9c %f%k%F{$pwd_bg_color}%K{$git_bg_color}\uE0B0%f%k%F{$git_fg_color}%K{$git_bg_color}$(parse_git_branch) %k%f%F{$git_bg_color}%K{$pyvenv_bg_color}\uE0B0%f%F{$pyvenv_fg_color}$(parse_env) %f%k%F{$pyvenv_bg_color}\uE0B0%f "
}
# PROMPT='$(powerline_prompt)'
PROMPT='$(minimal_prompt)'
RPROMPT='%F{#364f6b}$(date +'%H:%M:%S')%f'

#-----------------------------------------------------------------------------
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> MISC <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
#-----------------------------------------------------------------------------
# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
# Disable ctrl-s to freeze terminal.
stty stop undef
# Turn off all beeps
unsetopt BEEP
# Much snappier zsh-vim-mode
export KEYTIMEOUT=1

echo "\033[0;34m$(uptime)\033[0m"
