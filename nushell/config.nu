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

def gcm [msg: string] {
    git commit -am $msg
}

def nix-cmd [...args] {
    nix --extra-experimental-features 'nix-command flakes' ...$args
}

# exercism test command for common lisp (roswell)
def --env exetcl [] {
    let dir = $env.PWD

    if ($dir | str contains 'exercism/common-lisp') {
        let dirname = ($dir | path basename)
        let testfile = $"($dirname)-test.lisp"

        cd $dir

    let eval_expr = "(uiop:quit (if (" + $dirname + "-test:run-tests) 0 1))"
        
        run-external "ros" "run" "--load" $"./($testfile)" "--eval" $eval_expr
    } else {
        print "Not in an exercism common-lisp directory"
    }
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

$env.NVM_DIR = ($env.HOME | path join ".nvm")
# This function lets you run nvm via bash
def nvm [...args] {
  bash -c $"source ($env.NVM_DIR | path join 'nvm.sh'); nvm ($args | str join ' ')"
}

# PATH initialization
$env.PATH = ($env.PATH
    | prepend $"($env.HOME)/.bun/bin"
    | prepend $"($env.HOME)/.cargo/bin"
    | prepend $"($env.HOME)/.ghcup/bin"
    | append $"($env.HOME)/.zvm/bin"
    | append $"($env.HOME)/.zvm/self"
    | prepend $"($env.HOME)/go/bin"
    | uniq)

zoxide init nushell | save -f ~/.zoxide.nu
source ~/.zoxide.nu

# Starship initialization
mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
source ~/.cache/starship/init.nu

# Nvim environment variables
# source-env ~/.config/nvim/env.nu
