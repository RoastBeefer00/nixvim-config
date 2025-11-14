{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Dependencies
  #
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html?highlight=extraplugins#extrapackages
  extraPackages = with pkgs; [
    # Used to format Lua code
    stylua
    gosimports
    gofumpt
    prettier
    prettierd
    nixfmt
  ];

  # Autoformat
  # https://nix-community.github.io/nixvim/plugins/conform-nvim.html
  plugins.conform-nvim = {
    enable = true;
    settings = {
      notifyOnError = false;
      # format_on_save = {
      #   lspFallback = true;
      #   timeoutMs = 500;
      # };
      formattersByFt = {
        lua = [ "stylua" ];
        # Conform can also run multiple formatters sequentially
        # python = [ "isort "black" ];
        go = [
          "goimports"
          "gofumpt"
        ];

        nix = [ "nixfmt" ];
        #
        # You can use a sublist to tell conform to run *until* a formatter
        # is found
        javascript = [
          [
            "prettierd"
            "prettier"
          ]
        ];
        svelte = [
          [
            "prettierd"
            "prettier"
          ]
        ];
      };
    };
  };

  # https://nix-community.github.io/nixvim/keymaps/index.html
  keymaps = [
    {
      mode = "";
      key = "<leader>f";
      action.__raw = ''
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end
      '';
      options = {
        desc = "[F]ormat buffer";
      };
    }
  ];
}
