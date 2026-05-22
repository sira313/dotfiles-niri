
# Install Node.js with NVM on Fish Shell (Arch Linux)

## Install fish-nvm
```fish
paru -S fish-nvm
```

## Configure Fish
Open Fish config:
```fish
micro ~/.config/fish/config.fish
```
Add this line:
```fish
nvm use default --silent >/dev/null 2>&1
```
Save the file.

## Install Node.js LTS
```fish
nvm install lts
```

## Use Node.js LTS
```fish
nvm use lts
```

## Set Default Node.js Version
```fish
set -Ux nvm_default_version lts
```

## Restart Terminal
Close and reopen the terminal.
## Verify Installation
```fish
which node
node -v
npm -v
npx -v
```
# Install pnpm
## Enable Corepack
```fish
corepack enable
```

## Install and Activate pnpm
```fish
corepack prepare pnpm@latest --activate
```

## Verify pnpm
```fish
pnpm -v
```