{ ... }:
{
  plugins.crates = {
    enable = true;
    settings = {
      completion = {
        crates = {
          enabled = true;
        };
      };
    };
  };
}
