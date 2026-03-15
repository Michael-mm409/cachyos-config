# ~/.config/fish/config.fish
source /usr/share/cachyos-fish-config/cachyos-config.fish

# 1. MAMBA INITIALIZATION (Must be BEFORE the prompt)
set -gx MAMBA_EXE "/usr/bin/micromamba"
set -gx MAMBA_ROOT_PREFIX "/home/michael/micromamba"
set -gx MAMBA_PROMPT_PATH 0  # Tell Mamba not to touch the prompt
$MAMBA_EXE shell hook --shell fish --root-prefix $MAMBA_ROOT_PREFIX | source
alias conda='micromamba'

# 2. ALIASES
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias resource='source ~/.config/fish/config.fish'
alias bashrc='micro ~/.config/fish/config.fish'
alias obsidian='obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland'

alias uni-pull='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" /mnt/proxmox_uni/ ~/Documents/University/'
alias uni-push='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ /mnt/Synology_Home/Documents/University/University/'
alias uni-status='mutagen sync list; and echo "--- Hub Connectivity ---"; and ping -c 1 100.70.100.118 | grep "time="'

# --- MICHAEL'S CUSTOM PROMPT ---

# 1. LEFT SIDE: Environment (CONDA), User, Host, and Path
function fish_prompt
    if set -q CONDA_DEFAULT_ENV
        set_color yellow
        echo -n "($CONDA_DEFAULT_ENV) "
        set_color normal
    end

    set_color blue
    echo -n "["(whoami)
    set_color white
    echo -n "@"
    set_color magenta
    echo -n (hostname)" "
    set_color yellow
    echo -n (prompt_pwd)
    set_color blue
    echo -n "]"
    set_color normal
    echo -n "\$ "
end

# 2. RIGHT SIDE: Git Branch Status
function fish_right_prompt
    # Check if we are in a git repo using standard git tools
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1
        set_color cyan
        echo -n (fish_git_prompt)
        set_color normal
    end
end
alias uni-status='mutagen sync list && echo "--- Hub Connectivity ---" && ping -c 1 100.70.100.118 | grep "time="'
set -gx EDITOR micro
set -gx VISUAL micro

# Auto-start SSH agent and add your travel key
if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c)
    set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
    set -Ux SSH_AGENT_PID $SSH_AGENT_PID
end

# Add key if it's not already loaded
if not ssh-add -l | grep -q id_ed25519_desktop
    ssh-add ~/.ssh/id_ed25519_desktop 2>/dev/null
end
