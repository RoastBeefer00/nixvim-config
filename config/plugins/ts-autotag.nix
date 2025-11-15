{ pkgs, ... }:
{
  extraConfigLua = ''
    require("nvim-ts-autotag").setup({})
  '';
}
