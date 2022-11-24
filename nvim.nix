{ config, lib, pkgs, ... }:

let
  pluginGit = owner: repo: ref: sha: pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "${repo}";
    version = ref;
    src = pkgs.fetchFromGitHub {
      owner = owner;
      repo = repo;
      rev = ref;
      sha256 = sha;
    };
  };
  plugin = pluginGit "HEAD";

  nvim = pkgs.neovim.override {
    vimAlias = true;
    configure = {
      packages.myPlugins = with pkgs.vimPlugins; {
        start = [
          nvim-treesitter.withAllGrammars
          nvim-lspconfig
          fzf-lua
          nvim-web-devicons
          cmp-buffer
          cmp-nvim-lsp
          cmp-nvim-lsp-signature-help
          nvim-cmp
          nerdcommenter

          vim-sleuth

          gitsigns-nvim
          null-ls-nvim
          nvim-jdtls
          indent-blankline-nvim-lua

          kanagawa-nvim
          lualine-nvim
        ];
      };
      customRC = ''
        lua << EOF
          ${lib.strings.fileContents ./dotfiles/nvim/init.lua}
        EOF
      '';
    };
  };

in {
  environment.systemPackages = [ nvim ];
}
