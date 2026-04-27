# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ~/.zshrc

# 0. CACHYOS INTEGRATION
# Note: Zsh doesn't use the fish-config, but CachyOS has zsh defaults too.
[[ -f /usr/share/zsh/scripts/antidote/antidote.zsh ]] && source /usr/share/zsh/scripts/antidote/antidote.zsh

# 1. ALIASES
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias resource='source ~/.zshrc'
alias bashrc='micro ~/.zshrc'
alias obsidian='obsidian --enable-features=UseOzonePlatform --ozone-platform=wayland'

alias uni-pull='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" /mnt/proxmox_uni/ ~/Documents/University/'
alias uni-push='rsync -avzu --no-perms --no-owner --no-group --exclude=".conda/" ~/Documents/University/ /mnt/Synology_Home/Documents/University/University/'
alias uni-status='mutagen sync list && echo "--- Hub Connectivity ---" && ping -c 1 100.70.100.118 | grep "time="'
alias unisync='/usr/local/bin/unisync'
alias unilog='tail -f ~/cachyos-config/sync.log'

# 2. ENVIRONMENT VARIABLES
export TERM=xterm-256color
export TERMINFO_DIRS=/usr/share/terminfo
export EDITOR=micro
export VISUAL=micro
export GTK_USE_PORTAL=1
export XDG_CURRENT_DESKTOP=KDE
export XDG_MENU_PREFIX=plasma-

# 3. SSH AGENT AUTO-START
if ! pgrep -u $USER ssh-agent > /dev/null; then
    eval $(ssh-agent -s) > /dev/null
else
    export SSH_AUTH_SOCK=$(find /tmp -type s -name "agent.*" -user $USER 2>/dev/null | head -n 1)
fi

# Add key if it's not already loaded
if ! ssh-add -l >/dev/null 2>&1; then
    if [[ -f ~/.ssh/id_ed25519_desktop ]]; then
        ssh-add ~/.ssh/id_ed25519_desktop 2>/dev/null
    fi
fi

# 4. CONDA INITIALIZATION
if [ -f "/opt/miniconda3/bin/conda" ]; then
    __conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
            . "/opt/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="/opt/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi

# 5. UNIVERSITY AUTO-ENV SYNC (Zsh chpwd function)
# In Zsh, 'chpwd' runs automatically whenever you change directories
university_auto_env_sync() {
    local uni_base="$HOME/Documents/University"
    
    # 1. THE EXIT GUARD: If we leave the University root entirely
    if [[ "$PWD" != "$uni_base"* ]]; then
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            conda deactivate
        fi
        return
    fi

    # 2. FIND THE SUBJECT FOLDER: Look up the path for "Code - Name"
    # This works even if you are 5 folders deep in 'Assessments/Final/Code'
    local subject_path=$(echo "$PWD" | grep -oP "$uni_base/.*?/[^/]+ - [^/]+")
    
    if [[ -n "$subject_path" ]]; then
        # Extract just the code (e.g., CSC5020)
        local subject_folder="${subject_path##*/}"
        local subject_code="${subject_folder%% - *}"
        
        # 3. ACTIVATION LOGIC
        if [[ -d "$HOME/.conda/envs/$subject_code" ]]; then
            if [[ "$CONDA_DEFAULT_ENV" != "$subject_code" ]]; then
                conda activate "$subject_code"
            fi
            return
        fi
    fi

    # 4. THE NEUTRAL ZONE: If in University but not in a subject subfolder
    if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
        conda deactivate
    fi
}

# Add the function to the list of directory change hooks
autoload -U add-zsh-hook
add-zsh-hook chpwd university_auto_env_sync

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
