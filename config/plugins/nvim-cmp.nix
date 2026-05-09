{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # luasnip — used by blink-cmp as snippet engine
  plugins.luasnip = {
    enable = true;
  };

  # TODO: Waiting on this bug to be fixed https://github.com/NixOS/nixpkgs/issues/306367
  extraLuaPackages = ps: [
    ps.jsregexp
  ];
}
