if status is-interactive

    set -g fish_greeting ""
    starship init fish | source


end

# cursor global
set -gx XCURSOR_THEME Qogir-Ubuntu-Dark
set -gx XCURSOR_SIZE 24
set -gx PATH $HOME/.local/bin $PATH