{ ... }:
{
  plugins.markdown-preview = {
    enable = true;
    settings = {
      browser = "";
      auto_close = 1;
    };
  };
  keymaps = [
    {
      mode = "n";
      key = "<leader>mp";
      action = "<cmd>MarkdownPreviewToggle<cr>";
      options.desc = "Toggle markdown preview";
    }
  ];
}
