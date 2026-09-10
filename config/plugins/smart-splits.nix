{ ... }:
{
  plugins.smart-splits = {
    enable = true;
  };

  # When running inside herdr, navigate to adjacent herdr panes at the neovim
  # split edge instead of wrapping. Outside herdr, smart-splits auto-detects
  # the multiplexer (tmux etc.) and uses its default edge behavior.
  extraConfigLua = ''
    if vim.env.HERDR_ENV == '1' then
      require('smart-splits').setup({
        multiplexer_integration = false,
        at_edge = function(ctx)
          local dir_map = { left = 'left', right = 'right', up = 'up', down = 'down' }
          local dir = dir_map[ctx.direction]
          if dir then
            vim.fn.jobstart({ 'herdr', 'pane', 'focus', '--direction', dir })
          end
        end,
      })
    end
  '';
}
