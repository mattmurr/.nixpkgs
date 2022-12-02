{ config, lib, pkgs, ... }:

let
  pluginGit = ref: repo: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${lib.strings.sanitizeDerivationName repo}";
    version = ref;
    src = builtins.fetchGit {
      url = "https://github.com/${repo}.git";
      ref = ref;
    };
  };
  plugin = pluginGit "HEAD";

  nvim = pkgs.neovim.override {
    configure = {
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          nvim-tree-lua
          nvim-web-devicons
          nvim-treesitter.withAllGrammars
          nvim-lspconfig
          nvim-web-devicons
          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          cmp_luasnip
          luasnip
          nvim-cmp
          nerdcommenter

          zk-nvim

          telescope-nvim
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          
          vim-sleuth

          gitsigns-nvim
          null-ls-nvim
          nvim-jdtls
          indent-blankline-nvim-lua

          kanagawa-nvim
          lualine-nvim

          (plugin "WhoIsSethDaniel/lualine-lsp-progress.nvim")
        ];
      };
      customRC = ''
      lua << EOF
      require'init'
      EOF
      '';
    };
  };

in {
  environment.systemPackages = [ nvim ];
}
