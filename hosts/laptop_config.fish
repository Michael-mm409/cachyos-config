# ~/.config/fish/config.fish
source /usr/share/cachyos-fish-config/cachyos-config.fish

# 1. ALIASES
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias resource='source ~/.config/fish/config.fish'
alias bashrc='micro ~/.config/fish/config.fish'
alias obsidian='obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland'

alias uni-pull='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" /mnt/proxmox_uni/ ~/Documents/University/'
alias uni-push='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ /mnt/Synology_Home/Documents/University/University/'
alias uni-status='mutagen sync list; and echo "--- Hub Connectivity ---"; and ping -c 1 100.70.100.118 | grep "time="'
alias unisync='/usr/local/bin/unisync'
alias unilog='tail -f ~/cachyos-config/sync.log'

# --- MICHAEL'S CUSTOM  PROMPT ---

# 2. LEFT SIDE: Environment (CONDA), User, Host, and Path
function fish_prompt
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

set -gx TERM xterm-256color
set -gx TERMINFO_DIRS /usr/share/terminfo
set -gx EDITOR micro
set -gx VISUAL micro
set -gx GTK_USE_PORTAL 1

# Force VS Code to use the correct portal backend
set -gx XDG_CURRENT_DESKTOP KDE
set -gx XDG_MENU_PREFIX plasma-

# Auto-start SSH agent (Improved & Error-Free)
if not pgrep -u $USER ssh-agent > /dev/null
    eval (ssh-agent -c) > /dev/null
else
    # We use 'string collect' and 'path' to handle wildcards safely in Fish
    set -l agent_sock (find /tmp -type s -name "agent.*" -user $USER 2>/dev/null | head -n 1)
    if test -n "$agent_sock"
        set -gx SSH_AUTH_SOCK $agent_sock
    end
end

# Add key if it's not already loaded
if not ssh-add -l >/dev/null 2>&1
    if test -f ~/.ssh/id_ed25519_desktop
        ssh-add ~/.ssh/id_ed25519_desktop 2>/dev/null
    end
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/miniconda3/bin/conda
    eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
        . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/miniconda3/bin" $PATH
    end
end

# <<< conda initialize <<<

function university_auto_env_sync --on-variable PWD
    set -l uni_base "$HOME/Documents/University"
    
    # 1. THE EXIT GUARD
    # If we are NOT in the University folder at all, kill any active conda env
    if not string match -q "$uni_base*" "$PWD"
        if set -q CONDA_DEFAULT_ENV
            conda deactivate
        end
        return
    end

    # 2. THE SUBJECT CHECK
    # Check if we are inside a folder with the "Code - Name" format
    if string match -q "* - *" "$PWD"
        # Extract the code (e.g., CSC5020)
        set -l subject_code (string split "/" "$PWD")[-1]
        set -l subject_code (string split " - " "$subject_code")[1]
        
        # 3. ACTIVATION LOGIC
        if test -d "$HOME/.conda/envs/$subject_code"
            # Switch if we aren't already in the right one
            if not set -q CONDA_DEFAULT_ENV; or test "$CONDA_DEFAULT_ENV" != "$subject_code"
                set_color yellow
                echo "Switching to Environment: $subject_code"
                set_color normal
                conda activate "$subject_code"
            end
            return
        end
    end

    # 4. THE NEUTRAL ZONE
    # If we are in University but NOT in a specific subject folder, revert to base or deactivate
    if set -q CONDA_DEFAULT_ENV; and test "$CONDA_DEFAULT_ENV" != "base"
        conda deactivate
    end
end
