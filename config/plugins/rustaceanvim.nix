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
        on_attach.__raw = ''
          function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end
        '';
        default_settings = {
          rust-analyzer = {
            cargo = {
              buildScripts.enable = true;
            };
            check.command = "clippy";
            procMacro.enable = true;
            inlayHints = {
              bindingModeHints.enable = true;
              closureCaptureHints.enable = true;
              closureReturnTypeHints.enable = "always";
              lifetimeElisionHints = {
                enable = "skip_trivial";
                useParameterNames = true;
              };
            };
          };
        };
      };
    };
  };
}
