# ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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

# 3. FAST SSH AGENT (Safe Version)
if ! pgrep -u $USER ssh-agent > /dev/null; then
    eval $(ssh-agent -s) > /dev/null
else
    # (N) prevents the "no matches found" error if the folder is empty
    export SSH_AUTH_SOCK=$(echo /tmp/ssh-*/agent.*(N[1]))
fi

# 4. FAST CONDA INITIALIZATION
if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/miniconda3/etc/profile.d/conda.sh"
else
    export PATH="/opt/miniconda3/bin:$PATH"
fi

# 5. UNIVERSITY AUTO-ENV SYNC
university_auto_env_sync() {
    local root_home="$HOME/Documents/University"
    local root_mnt="/mnt/Data/University"

    [[ ! -d "$root_home" ]] && root_home="/dev/null"
    [[ ! -d "$root_mnt" ]] && root_mnt="/dev/null"

    # 1. THE EXIT GUARD - Now keeps 'base' active instead of full deactivation
    if [[ "$PWD" != "$root_home"* ]] && [[ "$PWD" != "$root_mnt"* ]]; then
        if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
            conda activate base
        fi
        return
    fi

    # 2. FIND THE SUBJECT CODE
    local subject_code=$(echo "$PWD" | grep -oP "(?<=[0-9]{4}/)[A-Z]{3}[0-9]{4}(?= - )" | head -n 1)
    if [[ -z "$subject_code" ]]; then
        subject_code=$(echo "$PWD" | grep -oP "[A-Z]{3}[0-9]{4}" | head -n 1)
    fi

    # 3. ACTIVATION LOGIC
    if [[ -n "$subject_code" ]]; then
        if [[ -d "$HOME/.conda/envs/$subject_code" ]]; then
            [[ "$CONDA_DEFAULT_ENV" != "$subject_code" ]] && conda activate "$subject_code"
            return
        fi
    fi

    # 4. NEUTRAL ZONE
    if [[ -n "$CONDA_DEFAULT_ENV" && "$CONDA_DEFAULT_ENV" != "base" ]]; then
        conda activate base
    fi
}

# Hooks and Startup
autoload -U add-zsh-hook
add-zsh-hook chpwd university_auto_env_sync
university_auto_env_sync

# 6. PERSONAL PROJECT AUTOMATION (direnv)
if command -v direnv > /dev/null; then
    eval "$(direnv hook zsh)"
fi

# 7. THE FINAL WORD (Source p10k ONCE at the very end)
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
