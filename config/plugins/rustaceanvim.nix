{ ... }:
{
  plugins.rustaceanvim = {
    enable = true;
    settings = {
      server = {
        default_settings = {
          rust-analyzer = {
            cargo = {
              features = "all";
            };
          };
        };
      };
    };
  };
}
