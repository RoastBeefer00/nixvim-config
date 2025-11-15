{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    harpoon2
  ];

  extraConfigLua = builtins.readFile ./harpoon.lua;
}
