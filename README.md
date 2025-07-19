# nixvim-config
# Installation

If not using standalone setup this installation process assumes you understand the basics of importing and adding dependencies to your .nix configuration files.

## Install External Dependencies

- Basic utils: `git`
- Clipboard tool (xclip/xsel/win32yank or other depending on platform)
- A [Nerd Font](https://www.nerdfonts.com/): optional, provides various icons
  - if you have it set `enable_nerd_fonts` in `nixvim.nix` to true
- Language Dependencies:
  - If you want to write Typescript, you will need `npm`
  - If you want to write Golang, you will need `go`
  - etc.

## Overview

You can use this repo in four ways:

| Use Case         | Method                                                                 |
|------------------|------------------------------------------------------------------------|
| Standalone Neovim| Run a bundled Neovim executable with kickstart.nixvim config, no setup |
| NixOS Module     | System-level integration on NixOS                                      |
| Home Manager     | User-level integration on any OS using Home Manager                    |
| nix-darwin       | User-level integration on macOS using nix-darwin                       |

---
## Use-cases

### 1. Standalone Usage (No Configuration Files Needed)

Install locally via:
```nix
nix profile install .
```
Update afterwards with:
```nix
nix profile upgrade nixvim-config
```

Run instantly without modifying any user or system configuration:
```nix
nix run github:RoastBeefer00/nixvim-config -- <FILE>
```
Or build your own runnable nvim that can be reused
```nix
nix build github:RoastBeefer00/nixvim-config
./result/bin/nvim <FILE>
```

### 2. NixOS Module
1. Add kickstart.nixvim to your `flake.nix`:
```nix
inputs.kickstart-nixvim.url = "github:RoastBeefer00/nixvim-config";
```
2. Import the nixosModules in your `configuration.nix`:
```nix
{
  imports = [
    inputs.kickstart-nixvim.nixosModules.default
  ];

  programs.nixvim.enable = true;
}
```

### 3. Home Manager Module
1. Add kickstart.nixvim to your `flake.nix`:
```nix
inputs.kickstart-nixvim.url = "github:RoastBeefer00/nixvim-config";
```
2. Import the homeManagerModules in your `home.nix`:
```nix
{
  imports = [
    inputs.kickstart-nixvim.homeManagerModules.default
  ];

  programs.nixvim.enable = true;
}
```

### 4. nix-darwin Module (macOS)
1. Add kickstart.nxivim to your `flake.nix`:
```nix
inputs.kickstart-nixvim.url = "github:RoastBeefer00/nixvim-config";
```
2. Import the darwinModules in your `darwin-configuration.nix`:
```nix
{
  imports = [
    inputs.kickstart-nixvim.darwinModules.default
  ];

  programs.nixvim.enable = true;
}
```
## Local configuration

>**NOTE**
> Backup your previous configuration (if any exists)
> This can be found on Linux under the path `$XDG_CONFIG_HOME/nvim` or `~/.config/nvim`

1. [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
so that you have your own copy that you can update and version control.
2. Clone kickstart.nixvim
    * If you created your own fork
      ```sh
      cd ~
      git clone https://github.com/<YOUR-GITHUB-USERNAME>/kickstart.nixvim.git
      ```
3. a. If you are using kickstart.nixvim with your own flake then update your flake.nix to refer to your local kickstart.nixvim repo
```nix
inputs.kickstart-nixvim.url = "path:<PATH_TO>/kickstart.nixvim";
```
3. b. Or if you are running kickstart.nixvim standalone run in your cloned repo directory
Note: For quick testing you can add any custom nixvim configurations into `/config/default.nix`
```nix
run build .
./result/bin/nvim
```
4. a. If you are using kickstart.nixvim with your own flake confirm the `init.lua` file has been created and loads without errors
```sh
nvim ~/.config/nvim/init.lua
``` 

# FAQ

* What should I do if I already have a pre-existing neovim configuration?
  * You should back it up and then delete all associated files.
  * This includes your existing init.lua and the neovim files in `~/.local`
    which can be deleted with `rm -rf ~/.local/share/nvim/`
* Can I keep my existing configuration in parallel to kickstart.nixvim?
  * Yes! You can use [NVIM_APPNAME](https://neovim.io/doc/user/starting.html#%24NVIM_APPNAME)`=nvim-NAME`
    to maintain multiple configurations. For example, move your old configuration to
    `~/.config/nvim-backup` and create an alias:
    ```
    alias nvim-backup='NVIM_APPNAME="nvim-backup" nvim'
    ```
    When you run Neovim using `nvim-backup` alias it will use the alternative
    config directory and the matching local directory
    `~/.local/share/nvim-backup`.
* What if I want to "uninstall" kickstart.nixvim:
   1. Remove kickstart-nixvim from your `flake.nix` and the module imports from you `configuration.nix`, `home.nix`, or `darwin-configuration.nix`
   2. Remove the kickstart.nixvim directory `rm -r ~/<PATH_TO>/kickstart.nixvim`
   3. Remove any .local nvim files `rm -rf ~/.local/share/nvim/`
   4. **Optional:** Move your previously backed up lua configuration files to `$XDG_CONFIG_HOME/nvim` or `~/.config/nvim`
   5. Rebuild your NixOS configuration `nixos-rebuild switch`

