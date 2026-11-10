# Follow the desktop's theme preset (nixos-config j713/themes.nix): it writes the colorscheme name to
# ~/.local/state/theme/current/nvim. Applied at startup and live in every open Neovim when the preset changes.
# Without that file (other machines) Catppuccin Mocha stays, as set in default.nix.
{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    tokyonight-nvim
    rose-pine
    gruvbox-nvim
    kanagawa-nvim
    nord-nvim
    everforest
  ];

  extraConfigLuaPost = ''
    do
      local state = vim.fn.expand("~/.local/state/theme")

      local function apply()
        local f = io.open(state .. "/current/nvim")
        if not f then return end
        local name = vim.trim(f:read("*a") or "")
        f:close()
        if name ~= "" and name ~= vim.g.colors_name then
          vim.o.background = "dark"
          pcall(vim.cmd.colorscheme, name)
        end
      end

      apply()

      -- The switcher swaps the "current" link inside the state folder, which fires an event here.
      if vim.uv.fs_stat(state) then
        local watcher = vim.uv.new_fs_event()
        if watcher then
          watcher:start(state, {}, vim.schedule_wrap(apply))
          vim.api.nvim_create_autocmd("VimLeavePre", { callback = function() watcher:stop() end })
        end
      end
    end
  '';
}
