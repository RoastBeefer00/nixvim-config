{ ... }:
{
  plugins.rustaceanvim = {
    enable = true;
    settings = {
      tools = {
        hover_actions = {
          replace_builtin_hover = false;
        };
      };
      server = {
        capabilities.__raw = "require('blink.cmp').get_lsp_capabilities()";
        default_settings = {
          rust-analyzer = {
            cargo = {
              features = [ ];
            };
          };
        };
      };
    };
  };
}
