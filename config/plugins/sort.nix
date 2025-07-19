{ pkgs, ... }:
{
    extraPlugins = with pkgs.vimPlugins; [ sort-nvim ];

    extraConfigLua = ''
      require("sort").setup({})
    '';
}
