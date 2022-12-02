{ config, pkgs, ... }:

let
  nerdfonts = (pkgs.nerdfonts.override { fonts = [ "Meslo" ]; });

  nodePackages = import ./node-env/default.nix {
    inherit pkgs;
  };

  jdtls = pkgs.jdt-language-server.overrideAttrs (old: rec {
    version = "1.19.0";
    timestamp = "202212020539";
    src = builtins.fetchurl {
      url = "https://download.eclipse.org/jdtls/snapshots/${version}/jdt-language-server-${version}-${timestamp}.tar.gz";
      sha256 = "17j9cpw9jg9l2y9gb1wc90xrbryymfw5dighhag6z1sjh2bkzwdj";
    };
  });
in
{
  nixpkgs.config.allowUnfree = true;

  fonts = {
    fontDir.enable = true;
    fonts = [ nerdfonts ];
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.git
      pkgs.gnupg
      pkgs.fd
      pkgs.ripgrep
      pkgs.fzf
      pkgs.lsd
      pkgs.bat
      pkgs.delta
      pkgs.unzip
      pkgs.deno
      jdtls
      pkgs.jdk
      pkgs.gradle
      pkgs.maven
      pkgs.aws-vault
      pkgs.awscli2
      pkgs.spring-boot
      pkgs.go
      pkgs.gopls
      pkgs.ltex-ls
      pkgs.rnix-lsp
      pkgs.ccls
      pkgs.nodejs-16_x
      pkgs.nodePackages.node2nix
      pkgs.nodePackages.vscode-langservers-extracted
      pkgs.nodePackages.markdownlint-cli
      pkgs.sumneko-lua-language-server
      pkgs.nodePackages.typescript-language-server
      pkgs.nodePackages."@astrojs/language-server"
      nodePackages."@fsouza/prettierd"
      pkgs.direnv
      pkgs.curlie
      pkgs.zk
    ];

  environment.variables = {
    EDITOR = "nvim";
    ZK_NOTEBOOK_DIR = "$HOME/notes";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;
  nix.extraOptions = ''
  experimental-features = nix-command flakes
  keep-outputs = true
  keep-derivations = true
  '';
  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    interactiveShellInit = ''
    alias ls='lsd'
    alias ll='ls -l'
    alias curl='curlie'

    plugins=(git direnv tmux vi-mode fzf)
    ZSH_TMUX_AUTOSTART=true
    VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
    VI_MODE_SET_CURSOR=true
    FZF_BASE=${pkgs.fzf.out}/share/fzf

    export FZF_DEFAULT_COMMAND="fd -t f --hidden --follow --exclude '.git' --ignore-file $HOME/.gitignore --color=always"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="fd -t d --hidden --follow --exclude '.git' --ignore-file $HOME/.gitignore --color=always"
    export FZF_DEFAULT_OPTS="--height 100% --layout=reverse --border --ansi"
    export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --style=numbers --color=always --line-range :500 {}'"

    ZSH_THEME="cloud"
    . ${pkgs.oh-my-zsh.out}/share/oh-my-zsh/oh-my-zsh.sh
    eval "$(direnv hook zsh)"
    '';

  };

  programs.tmux.enable = true;

  imports = [
    ./nvim.nix
  ];

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
