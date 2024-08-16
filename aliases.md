# Use
`~/.bashrc`

after editing use
`source ~/.bashrc`

# Custom additions, append at the end of the file
```
#! BEGIN CUSTOM

# date and time formatting in bash history
HISTTIMEFORMAT="%F %T "

# Avoid duplicates
HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# After each command, append to the history file and reread it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"

# Show all files
alias ls='ls -lisa --color --group-directories-first'

# Docker Compose
alias dc='docker compose'

# Docker Compose Logs
alias dcl='docker compose logs --follow'

# Switch to my default docker directory
alias cdd='cd /docker'

# Press c to clear the terminal screen.
alias c='clear'

# Press h to view the bash history.
alias h='history'

# Move to the parent folder.
alias ..='cd ..'

# Move up two parent folders.
alias ...='cd ../..'

# Move up three parent folders.
alias ....='cd ../../..'

#! END CUSTOM
```