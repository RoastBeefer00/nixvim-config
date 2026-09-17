{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "tf-nvim";
      version = "unstable-2026-01-24";
      src = pkgs.fetchFromGitHub {
        owner = "Allaman";
        repo = "tf.nvim";
        rev = "8e199c7a4df50932f25a6c8d8f8eaaeab5582842";
        hash = "sha256-jLFJhpHpaMaBe1OiarsWSgumo8d+9foSc6/PcyJ5eHI=";
      };
    })
  ];

  extraConfigLua = ''
    require('tf').setup({})

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'terraform',
      callback = function(ev)
        vim.keymap.set('n', '<leader>td', '<cmd>TerraformDocOpen<CR>', {
          buffer = ev.buf,
          desc = 'Terraform: Open Docs',
        })
      end,
    })
  '';
}
