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
        # get_lsp_capabilities(override, include_nvim_defaults) — the second
        # arg must be `true` or this starts from `{}` instead of nvim's real
        # defaults (silently dropping various capability fields). Correct
        # regardless, but NOT what fixes the file-watcher issue below —
        # rustaceanvim overrides that specific setting itself either way.
        capabilities.__raw = "require('blink.cmp').get_lsp_capabilities({}, true)";
        on_attach.__raw = ''
          function(client, bufnr)
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end
        '';
        default_settings = {
          rust-analyzer = {
            # rustaceanvim's own lsp/init.lua has a HACK (workaround for
            # neovim/neovim#28690) that force-sets this to "server" whenever
            # didChangeWatchedFiles.dynamicRegistration is present in
            # capabilities — which it always is, nvim declares it by
            # default. "server" makes rust-analyzer use its own internal
            # (notify-crate) file watcher instead of nvim's; on this
            # project that internal watcher's setup never completes, so
            # the "Roots Scanned" progress notification never sends its
            # closing event and gets stuck at 100% forever in the UI.
            # Setting it explicitly here is the only way to stop
            # rustaceanvim from overriding it — nvim's own watcher works
            # fine and actually closes the progress cleanly.
            files.watcher = "client";
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
