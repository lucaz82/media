# Use
`~/.bashrc`

after editing use
`source ~/.bashrc`

# Custom additions, append at the end of the file
```
#! BEGIN CUSTOM
alias ls='ls -lisa'

# date and time formatting in bash history
HISTTIMEFORMAT="%F %T "

alias dc='docker compose'
alias dcl='docker compose logs --follow'
alias cdd='cd /docker'

#Press c to clear the terminal screen.
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