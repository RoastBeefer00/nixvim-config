{ pkgs, ... }:
{
  plugins.neotest = {
    enable = true;
    settings = {
      adapters = [
        {
          __raw = ''
            require("neotest-rust")({
              args = { "--no-capture" },
            })
          '';
        }
      ];
    };
  };

  extraPlugins = with pkgs.vimPlugins; [
    neotest-rust
  ];

  extraPackages = with pkgs; [
    cargo-nextest
  ];

  keymaps = [
    {
      mode = "n";
      key = "<leader>tr";
      action.__raw = ''function() require("neotest").run.run() end'';
      options.desc = "[T]est [R]un nearest";
    }
    {
      mode = "n";
      key = "<leader>tR";
      action.__raw = ''function() require("neotest").run.run(vim.fn.expand("%")) end'';
      options.desc = "[T]est [R]un file";
    }
    {
      mode = "n";
      key = "<leader>ts";
      action.__raw = ''function() require("neotest").summary.toggle() end'';
      options.desc = "[T]est [S]ummary";
    }
    {
      mode = "n";
      key = "<leader>to";
      action.__raw = ''function() require("neotest").output_panel.toggle() end'';
      options.desc = "[T]est [O]utput";
    }
    {
      mode = "n";
      key = "<leader>tl";
      action.__raw = ''function() require("neotest").run.run_last() end'';
      options.desc = "[T]est run [L]ast";
    }
  ];
}
