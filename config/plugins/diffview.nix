{ ... }:
{
  plugins.diffview = {
    enable = true;
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>gd";
      action = "<cmd>DiffviewOpen<cr>";
      options.desc = "Open diffview";
    }
    {
      mode = "n";
      key = "<leader>gD";
      action = "<cmd>DiffviewClose<cr>";
      options.desc = "Close diffview";
    }
  ];
}
