{ ... }:
{
  plugins.copilot-lua = {
    enable = true;
    # Keep suggestions disabled to avoid conflicts with Sidekick
    settings = {
      suggestion = {
        enabled = false;
      };
      panel = {
        enabled = false;
      };
    };
  };

  plugins.sidekick = {
    enable = true;
    settings = {
      cli = {
        mux = {
          backend = "tmux";
          enabled = true;
        };
      };
    };
  };

  # Sidekick keymaps
  keymaps = [
    # Tab key for next edit suggestion with fallback
    {
      mode = "n";
      key = "<Tab>";
      action.__raw = ''
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end
      '';
      options = {
        expr = true;
        desc = "Goto/Apply Next Edit Suggestion";
      };
    }

    # Ctrl+. to toggle Sidekick
    {
      mode = [
        "n"
        "t"
        "i"
        "x"
      ];
      key = "<C-.>";
      action.__raw = ''
        function()
          require("sidekick.cli").toggle()
        end
      '';
      options = {
        desc = "Sidekick Toggle";
      };
    }

    # Leader aa - Toggle CLI
    {
      mode = "n";
      key = "<leader>aa";
      action.__raw = ''
        function()
          require("sidekick.cli").toggle()
        end
      '';
      options = {
        desc = "Sidekick Toggle CLI";
      };
    }

    # Leader as - Select CLI
    {
      mode = "n";
      key = "<leader>as";
      action.__raw = ''
        function()
          require("sidekick.cli").select()
          -- Or to select only installed tools:
          -- require("sidekick.cli").select({ filter = { installed = true } })
        end
      '';
      options = {
        desc = "Select CLI";
      };
    }

    # Leader ad - Detach CLI Session
    {
      mode = "n";
      key = "<leader>ad";
      action.__raw = ''
        function()
          require("sidekick.cli").close()
        end
      '';
      options = {
        desc = "Detach a CLI Session";
      };
    }

    # Leader at - Send This (works in normal and visual mode)
    {
      mode = [
        "x"
        "n"
      ];
      key = "<leader>at";
      action.__raw = ''
        function()
          require("sidekick.cli").send({ msg = "{this}" })
        end
      '';
      options = {
        desc = "Send This";
      };
    }

    # Leader af - Send File
    {
      mode = "n";
      key = "<leader>af";
      action.__raw = ''
        function()
          require("sidekick.cli").send({ msg = "{file}" })
        end
      '';
      options = {
        desc = "Send File";
      };
    }

    # Leader av - Send Visual Selection
    {
      mode = "x";
      key = "<leader>av";
      action.__raw = ''
        function()
          require("sidekick.cli").send({ msg = "{selection}" })
        end
      '';
      options = {
        desc = "Send Visual Selection";
      };
    }

    # Leader ap - Sidekick Select Prompt
    {
      mode = [
        "n"
        "x"
      ];
      key = "<leader>ap";
      action.__raw = ''
        function()
          require("sidekick.cli").prompt()
        end
      '';
      options = {
        desc = "Sidekick Select Prompt";
      };
    }

    # Leader ac - Toggle Claude directly
    {
      mode = "n";
      key = "<leader>ac";
      action.__raw = ''
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end
      '';
      options = {
        desc = "Sidekick Toggle Claude";
      };
    }
  ];
}
