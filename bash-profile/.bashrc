# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -lF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

bind 'set bell-style none'

function precat() {
    URL=$(aws s3 presign $1); curl -s $URL
}

# export SCREENDIR="$HOME/.screen/"

export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export PATH="$HOME/helpers:$PATH"

function mkvenv() {
    python3 -m venv "$HOME/.venvs/$1"
}

function workon() {
 source "$HOME/.venvs/$1/bin/activate"  # commented out by conda initialize
}
_workon_complete()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local completion_results=$(ls "$HOME/.venvs/")
    COMPREPLY=( $(compgen -W "${completion_results}" -- $cur) )
}
complete -F _workon_complete workon

## uncomment if using conda...
## >>> conda initialize >>>
## !! Contents within this block are managed by 'conda init' !!
#__conda_setup="$("$HOME/anaconda3/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
#if [ $? -eq 0 ]; then
#    eval "$__conda_setup"
#else
#    if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
#        . "$HOME/anaconda3/etc/profile.d/conda.sh"
#    else
#        export PATH="$HOME/anaconda3/bin:$PATH"
#    fi
#fi
#unset __conda_setup
## <<< conda initialize <<<
#

# fix brew for M1
# eval $(/opt/homebrew/bin/brew shellenv)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PS1 helpers

PS1_GIT_BRANCH_NAME=''
function parse_git_branch() {
  git status > /dev/null 2> /dev/null
  if [ $? -eq 0 ]; then
    branch_name=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    branch_name_short=$(echo "$branch_name" | cut -c 1-30)
    PS1_GIT_BRANCH_NAME="{${branch_name_short}}"
  else
    PS1_GIT_BRANCH_NAME=''
  fi
}

PS1_AWS_PROFILE=''
function update_ps1_aws_profile() {
  if [ -z "${AWS_PROFILE}" ]; then
    PS1_AWS_PROFILE=''
  else
    PS1_AWS_PROFILE="[$AWS_PROFILE]"
  fi
}

PS1_AWS_GIT_SEPARATOR=''
function update_ps1_aws_git_separator() {
  if [ -z "$PS1_AWS_PROFILE" ] || [ -z "$PS1_GIT_BRANCH_NAME" ]; then
    PS1_AWS_GIT_SEPARATOR=''
  else
    PS1_AWS_GIT_SEPARATOR=' '
  fi
}

PS1_PASSWORD_STORE_DIR=''
function update_ps1_password_store_dir() {
	if [ -z "${PASSWORD_STORE_DIR}" ]; then
		PS1_PASSWORD_STORE_DIR=''
	else
		TMP_PASS_NAME=$(basename $PASSWORD_STORE_DIR | cut -d'-' -f 1 | sed 's/\.//g')
		PS1_PASSWORD_STORE_DIR="|$TMP_PASS_NAME|"
	fi
}

PS1_GIT_PASS_SEPARATOR=''
function update_ps1_git_pass_separator() {
	if [ -z "$PS1_PASSWORD_STORE_DIR" ]; then
		PS1_GIT_PASS_SEPARATOR=''
  else
		PS1_GIT_PASS_SEPARATOR=' '
	fi
}

function update_ps1_vars() {
  update_ps1_aws_profile
  parse_git_branch
  update_ps1_aws_git_separator
  update_ps1_password_store_dir
  update_ps1_git_pass_separator
}

PROMPT_COMMAND='update_ps1_vars'
export PS1="\$PS1_AWS_PROFILE\$PS1_AWS_GIT_SEPARATOR\$PS1_GIT_BRANCH_NAME\$PS1_GIT_PASS_SEPARATOR\$PS1_PASSWORD_STORE_DIR $PS1"

# pass tab completion
# https://github.com/stuartsierra/password-store/blob/master/src/completion/pass.bash-completion
_pass_complete_entries () {
	prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store/}"
	suffix=".gpg"
	autoexpand=${1:-0}

	local IFS=$'\n'
	local items=($(compgen -f $prefix$cur))
	for item in ${items[@]}; do
		[[ $item =~ /\.[^/]*$ ]] && continue

		# if there is a unique match, and it is a directory with one entry
		# autocomplete the subentry as well (recursively)
		if [[ ${#items[@]} -eq 1 && $autoexpand -eq 1 ]]; then
			while [[ -d $item ]]; do
				local subitems=($(compgen -f "$item/"))
				local filtereditems=( )
				for item2 in "${subitems[@]}"; do
					[[ $item2 =~ /\.[^/]*$ ]] && continue
					filtereditems+=( "$item2" )
				done
				if [[ ${#filtereditems[@]} -eq 1 ]]; then
					item="${filtereditems[0]}"
				else
					break
				fi
			done
		fi

		# append / to directories
		[[ -d $item ]] && item="$item/"

		item="${item%$suffix}"
		COMPREPLY+=("${item#$prefix}")
	done
}

_pass_complete_folders () {
	prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store/}"

	local IFS=$'\n'
	local items=($(compgen -d $prefix$cur))
	for item in ${items[@]}; do
		[[ $item == $prefix.* ]] && continue
		COMPREPLY+=("${item#$prefix}/")
	done
}

_pass_complete_keys () {
	local IFS=$'\n'
	# Extract names and email addresses from gpg --list-keys
	local keys="$(gpg2 --list-secret-keys --with-colons | cut -d : -f 10 | sort -u | sed '/^$/d')"
	COMPREPLY+=($(compgen -W "${keys}" -- ${cur}))
}

_pass()
{
	COMPREPLY=()
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local commands="init ls find grep show insert generate edit rm mv cp git help version"
	if [[ $COMP_CWORD -gt 1 ]]; then
		local lastarg="${COMP_WORDS[$COMP_CWORD-1]}"
		case "${COMP_WORDS[1]}" in
			init)
				if [[ $lastarg == "-p" || $lastarg == "--path" ]]; then
					_pass_complete_folders
				else
					COMPREPLY+=($(compgen -W "-p --path" -- ${cur}))
					_pass_complete_keys
				fi
				;;
			ls|list|edit)
				_pass_complete_entries
				;;
			show|-*)
				COMPREPLY+=($(compgen -W "-c --clip" -- ${cur}))
				_pass_complete_entries 1
				;;
			insert)
				COMPREPLY+=($(compgen -W "-e --echo -m --multiline -f --force" -- ${cur}))
				_pass_complete_entries
				;;
			generate)
				COMPREPLY+=($(compgen -W "-n --no-symbols -c --clip -f --force -i --in-place" -- ${cur}))
				_pass_complete_entries
				;;
			cp|copy|mv|rename)
				COMPREPLY+=($(compgen -W "-f --force" -- ${cur}))
				_pass_complete_entries
				;;
			rm|remove|delete)
				COMPREPLY+=($(compgen -W "-r --recursive -f --force" -- ${cur}))
				_pass_complete_entries
				;;
			git)
				COMPREPLY+=($(compgen -W "init push pull config log reflog rebase" -- ${cur}))
				;;
		esac
	else
		COMPREPLY+=($(compgen -W "${commands}" -- ${cur}))
		_pass_complete_entries 1
	fi
}

complete -o filenames -o nospace -F _pass pass
