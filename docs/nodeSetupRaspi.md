
# Setup Node.js, NPM, PNPM in Fish Shell (Raspberry Pi OS Lite)

## Install dependency

```bash
sudo apt update
sudo apt install curl build-essential -y
```

## Install fisher

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
and fisher install jorgebucaran/fisher
```

## Install bass for bash compatibility

```fish
fisher install edc/bass
```

## Install NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
```

## Edit fish config

```bash
micro ~/.config/fish/config.fish
```

Use this config:

```fish
if status is-interactive
    set -g fish_greeting ""
    starship init fish | source
end

fish_add_path $HOME/.local/bin

set -gx PNPM_HOME $HOME/.local/share/pnpm
fish_add_path $PNPM_HOME/bin

set -gx NVM_DIR $HOME/.nvm

function nvm
    bass source $NVM_DIR/nvm.sh --no-use ';' nvm $argv
end

if status is-interactive
    alias ls="eza --icons=always --color=always --group-directories-first"
    alias ll="eza -l --icons=always --color=always --group-directories-first"
    alias la="eza -a --icons=always --group-directories-first"
    alias lla="eza -la --icons=always --group-directories-first"
end

```

## Reload fish config

```fish
source ~/.config/fish/config.fish

```

## Check NVM

```fish
nvm --version
```

## Install Node.js LTS

```fish
nvm install --lts
nvm alias default lts/*
```

## Check Node and NPM

```fish
node -v
npm -v
```

## Activate corepack

```fish
corepack enable
```

## Install PNPM

```fish
corepack prepare pnpm@latest --activate
```

## Check PNPM

```fish
pnpm -v
```

## Install global package

For exc PM2:

```fish
pnpm add -g pm2
```

## Check PM2

```fish
pm2 -v
```