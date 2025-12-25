{
  config,
  pkgs,
  inputs,
  ...
}:
{
  plugins.treesitter = {
    enable = true;
    
    # This tells nixvim to use Nix-provided grammars (pre-compiled)
    nixGrammars = true;
    
    # Specify which grammars you want (installed via Nix, not at runtime)
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      c
      css
      diff
      html
      javascript
      lua
      markdown
      nix
      svelte
      typescript
      vim
      vimdoc
      yaml
    ];
    
    settings = {
      indent.enable = true;
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = false;
      };
      # Remove these - they try to install at runtime:
      # auto_install = true;  # ❌ DON'T USE THIS
      # ensureInstalled = []; # ❌ DON'T USE THIS
    };
  };
}
