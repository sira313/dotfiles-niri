if status is-interactive

    set -g fish_greeting ""
    starship init fish | source


end

# cursor global
set -gx XCURSOR_THEME Qogir-Ubuntu-Dark
set -gx XCURSOR_SIZE 24
set -gx PATH $HOME/.local/bin $PATH

nvm use default --silent >/dev/null 2>&1

# use Eza for folder icon
if status is-interactive
    # Alias untuk menggantikan ls dengan eza + ikon Nerd Font
    alias ls="eza --icons=always --color=always --group-directories-first"
    alias ll="eza -l --icons=always --color=always --group-directories-first"
    alias la="eza -a --icons=always --color=always --group-directories-first"
    alias lla="eza -la --icons=always --color=always --group-directories-first"
end
# opencode
fish_add_path /home/aris/.opencode/bin
