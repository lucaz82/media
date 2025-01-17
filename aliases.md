# Setup custom aliases

### Debian

`~/.bashrc`

### Ubuntu

`~/.bash_aliases`

after editing use
`source ~/.bashrc`

<br/>

```bash
###! BEGIN CUSTOM

###########
# history #
###########

# Set how many history commands will be stored in memory.
HISTSIZE=1000

# Set how many history commands will be stored on disk.
HISTFILESIZE=3000

# date and time formatting in bash history
HISTTIMEFORMAT="%F %T "

# Ignore commands
HISTIGNORE="history:h:clear:c:ls*:ll*:dcl:* --help"

# Avoid duplicates
HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
#PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
PROMPT_COMMAND='history -a'

##########
# docker #
##########

alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs'
alias cdd='cd /docker'

########
# misc #
########

alias ls='ls -lha --color=auto --group-directories-first'
alias c='clear'
alias h='history'
alias ..='cd ..'

###! END CUSTOM
```
