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
def greet [name?: string] {
  let real_name = if $name != null { $name } else { $env.USER }
  $"Hello, ($real_name)!"
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
def --env mkcd [dirname: string] {
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

# Commands completions
let fish_completer = {|spans|
    fish --command $'complete "--do-complete=($spans | str join " ")"'
    | from tsv --flexible --noheaders --no-infer
    | rename value description
}

let carapace_completer = {|spans: list<string>|
    carapace $spans.0 nushell ...$spans
    | from json
    | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
}

# This completer will use carapace by default
let external_completer = {|spans|
    let expanded_alias = scope aliases
    | where name == $spans.0
    | get -i 0.expansion

    let spans = if $expanded_alias != null {
        $spans
        | skip 1
        | prepend ($expanded_alias | split row ' ' | take 1)
    } else {
        $spans
    }

    match $spans.0 {
        nu => $fish_completer
        git => $fish_completer
        asdf => $fish_completer
        _ => $carapace_completer
    } | do $in $spans
}

$env.config = {
    completions: {
        external: {
            enable: true
            completer: $external_completer
        }
    }
}

# PATH initialization
$env.PATH = ($env.PATH
    | prepend $"($env.HOME)/.bun/bin"
    | prepend $"($env.HOME)/.cargo/bin"
    | prepend $"($env.HOME)/.ghcup/bin"
    | append $"($env.HOME)/.zvm/bin"
    | append $"($env.HOME)/.zvm/self"
    | uniq)

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu

# Starship initialization
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
source ~/.cache/starship/init.nu
