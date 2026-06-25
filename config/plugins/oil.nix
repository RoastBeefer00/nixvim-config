{ ... }:
{
  plugins.oil = {
    enable = true;
    settings = {
      view_options = {
        show_hidden = true;
      };
      keymaps = {
        "<C-h>" = {
          callback.__raw = "require('smart-splits').move_cursor_left";
          desc = "Move to the left split";
        };
        "<C-j>" = {
          callback.__raw = "require('smart-splits').move_cursor_down";
          desc = "Move to the below split";
        };
        "<C-k>" = {
          callback.__raw = "require('smart-splits').move_cursor_up";
          desc = "Move to the above split";
        };
        "<C-l>" = {
          callback.__raw = "require('smart-splits').move_cursor_right";
          desc = "Move to the right split";
        };
      };
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "-";
      action = "<cmd>Oil<cr>";
    }
  ];
}
