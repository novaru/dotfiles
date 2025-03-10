# Set Fish greeting message
set fish_greeting ""

# Check and set the current Fish theme
# fish_config theme save "Catppuccin Mocha"

# Set BAT_THEME environment variable
set -Ux BAT_THEME "Dracula"

# PATH
set -x PATH $HOME/.ghcup/bin /usr/local/bin /usr/bin /bin /usr/local/sbin /usr/bin/site_perl /usr/bin/vendor_perl /usr/bin/core_perl $HOME/.cargo/bin 

# ALIASES
alias lt="lsd --tree --icon=never"
alias ll="lsd -la --icon=never"
alias c="clear"
alias zbr="zig build run"
alias ytdl="yt-dlp --cookies ~/Videos/yt-cookies.txt"
alias ytdf="yt-dlp -F --cookies ~/Videos/yt-cookies.txt"
alias exet="exercism test"
alias exes="exercism submit"

# Swap Keys
setxkbmap -option caps:swapescape

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
test -r '/home/novaru/.opam/opam-init/init.fish' && source '/home/novaru/.opam/opam-init/init.fish' > /dev/null 2> /dev/null; or true
# END opam configuration

# BUN
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

zoxide init fish | source
starship init fish | source

# ZVM
set -gx ZVM_INSTALL "$HOME/.zvm/self"
set -gx PATH $PATH "$HOME/.zvm/bin"
set -gx PATH $PATH "$ZVM_INSTALL/"
