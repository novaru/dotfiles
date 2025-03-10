# Default environment settings
$env.config = {
    show_banner: false
    ls: {
        use_ls_colors: true
        clickable_links: true
    }
    rm: {
        always_trash: false
    }
    table: {
        mode: rounded
        index_mode: always
        trim: {
            methodology: wrapping
            wrapping_try_keep_words: true
        }
    }
}

# Custom keybindings
$env.config.keybindings = [
    {
        name: completion_menu
        modifier: none
        keycode: tab
        mode: [emacs, vi_normal, vi_insert]
        event: {
            until: [
                { send: menu name: completion_menu }
                { send: menunext }
            ]
        }
    }
]

# Aliases
alias c = clear
alias ll = ls -la
alias dev = cd ~/dev
alias docs = cd ~/documents
alias dl = cd ~/downloads
alias z = __zoxide_z
alias zi = __zoxide_zi

alias zbr = zig build run
alias ytdl = yt-dlp --cookies ~/Videos/yt-cookies.txt
alias ytdf = yt-dlp -F --cookies ~/Videos/yt-cookies.txt
alias exet = exercism test
alias exes = exercism submit

alias g = git
alias gs = git status
alias gc = git commit
alias gp = git push

# Swap Keys
setxkbmap -option caps:swapescape

# Functions
def greet [] {
    echo "Hello, (sys | get host.hostname)!"
}

# Open a file with default associated program
def open [filename: path] {
    if $nu.os-info.name == "macos" {
        run-external "open" $filename
    } else if $nu.os-info.name == "windows" {
        run-external "start" $filename
    } else if $nu.os-info.name == "linux" {
        run-external "xdg-open" $filename
    }
}

# Create directory and enter it
def mkcd [dirname: string] {
    mkdir $dirname
    cd $dirname
}

# Display current Git branch
def git-branch [] {
    git branch --show-current | str trim
}

def nix-cmd [...args] {
    nix --extra-experimental-features 'nix-command flakes' ...$args
}

# BUN
$env.BUN_INSTALL = $"($env.HOME)/.bun"
$env.PATH = ($env.PATH | prepend $"($env.BUN_INSTALL)/bin")

# ZVM
$env.ZVM_INSTALL = $"($env.HOME)/.zvm/self"
$env.PATH = ($env.PATH | append $"($env.HOME)/.zvm/bin")
$env.PATH = ($env.PATH | append $env.ZVM_INSTALL)

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu

# Starship initialization
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
source ~/.cache/starship/init.nu
