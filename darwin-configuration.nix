{ lib, config, pkgs, ... }:
let
  lsp-colors = pkgs.vimUtils.buildVimPlugin {
    name = "lsp-colors";
    src = pkgs.fetchFromGitHub {
      owner = "folke";
      repo = "lsp-colors.nvim";
      rev = "00b40add53f2f6bd249932d0c0cd25a42ce7a2fc";
      sha256 = "1qa1kb5abrka5iixmz81kz4v8xrs4jv620nd583rhwya2jmkbaji";
    };
  };
  neovim = pkgs.neovim.override {
    configure = {
      plug.plugins = with pkgs.vimPlugins; [
        vim-nix
        fzf-vim
        vim-gitgutter
        vim-sleuth
        nvim-lspconfig
        nvim-jdtls
        nvim-compe
        nvim-treesitter
        lsp-colors
        vim-deus
        lightline-vim
        nerdcommenter
      ];
      customRC = ''
        set title
        autocmd BufEnter * let &titlestring = expand("%:t") . " - NVIM"
        set autoread
        autocmd CursorHold * checktime
        let mapleader=" "
        set number relativenumber
        set inccommand="nosplit"
        set hlsearch
        set ignorecase
        set smartcase
        set updatetime=250
        set signcolumn=yes
        set undofile
        set completeopt=menuone,noselect
        set t_Co=256
        set termguicolors
        let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
        let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
        set cursorline
        set background=dark
        colorscheme deus
        let g:deus_termcolors=256
        set rtp+=${pkgs.fzf.out}/share/vim-plugins/fzf
        let g:fzf_action = {
          \ 'ctrl-h': 'split',
          \ 'ctrl-v': 'vsplit' }
        let g:fzf_buffers_jump = 1
        noremap <leader>t :Files<CR>
        noremap <leader>g :GFiles<CR>
        noremap <leader>b :Buffers<CR>
        lua << EOF
        require"nvim-treesitter.configs".setup({
          ensure_installed = "maintained",
          ignore_install = {},
          indent = { enable = true },
          highlight = {
            enable = true,
            disable = {},
            additional_vim_regex_highlighting = false,
          }
        })
        local nvim_lsp = require('lspconfig')
        -- Use an on_attach function to only map the following keys
        -- after the language server attaches to the current buffer
        local on_attach = function(client, bufnr)
          local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
          local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
          -- Enable completion triggered by <c-x><c-o>
          buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')
          -- Mappings.
          local opts = { noremap=true, silent=true }
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
          buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
          buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
          buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
          buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
          buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
          buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
          buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
          buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
          buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
          buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
          buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
          buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
          buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
          buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
          buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
        end
        -- Use a loop to conveniently call 'setup' on multiple servers and
        -- map buffer local keybindings when the language server attaches
        local servers = { 'tsserver', 'ccls', 'pyright', 'gopls', 'rnix', 'jdtls' }
        for _, lsp in ipairs(servers) do
          nvim_lsp[lsp].setup {
            on_attach = on_attach,
            flags = {
              debounce_text_changes = 150,
            }
          }
        end
        require'compe'.setup {
          enabled = true;
          autocomplete = true;
          debug = false;
          min_length = 1;
          preselect = 'enable';
          throttle_time = 80;
          source_timeout = 200;
          incomplete_delay = 400;
          max_abbr_width = 100;
          max_kind_width = 100;
          max_menu_width = 100;
          documentation = true;
          source = {
            path = true;
            nvim_lsp = true;
            treesitter = true;
          };
        }
        local t = function(str)
          return vim.api.nvim_replace_termcodes(str, true, true, true)
        end
        local check_back_space = function()
            local col = vim.fn.col('.') - 1
            if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                return true
            else
                return false
            end
        end
        -- Use (s-)tab to:
        --- move to prev/next item in completion menuone
        --- jump to prev/next snippet's placeholder
        _G.tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return t "<C-n>"
          elseif check_back_space() then
            return t "<Tab>"
          else
            return vim.fn['compe#complete']()
          end
        end
        _G.s_tab_complete = function()
          if vim.fn.pumvisible() == 1 then
            return t "<C-p>"
          else
            return t "<S-Tab>"
          end
        end
        vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
        vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
        vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
        vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
        --This line is important for auto-import
        vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
        vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
        EOF
      '';
    };
  };
  isAppleSilicon = (pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64);
in
{
  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    InitialKeyRepeat = 15;
    KeyRepeat = 1;
    "com.apple.trackpad.scaling" = "2";
    AppleMeasurementUnits = "Centimeters";
    AppleMetricUnits = 1;
    AppleTemperatureUnit = "Celsius";
  };

  system.defaults.finder = {
    AppleShowAllExtensions = true;
    QuitMenuItem = true;
    FXEnableExtensionChangeWarning = false;
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  system.defaults.trackpad = {
    ActuationStrength = 0;
    FirstClickThreshold = 0;
    SecondClickThreshold = 0;
  };

  system.defaults.LaunchServices.LSQuarantine = false;

  # Allow non-free software
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    [
      pkgs.gnupg
      pkgs.git
      pkgs.openssh
      pkgs.fd
      pkgs.ripgrep
      pkgs.fzf
      pkgs.bat
      pkgs.jq
      (
        pkgs.pass.withExtensions (ext: with ext; [ pass-otp ])
      )
      pkgs.pinentry_mac
      neovim
      pkgs.oh-my-zsh
      pkgs.alacritty
      pkgs.direnv
      pkgs.python38
      pkgs.pyright
      pkgs.nodejs-16_x
      pkgs.nodePackages.typescript
      pkgs.nodePackages.typescript-language-server
      pkgs.gopls
      pkgs.rnix-lsp
      pkgs.go
      pkgs.deno
      pkgs.spring-boot
      pkgs.vscode
      pkgs.awscli2
      pkgs.aws-vault
      pkgs.google-cloud-sdk
      pkgs.jdk11
    ];

  homebrew = {
    enable = true;
    autoUpdate = true;
    brewPrefix = lib.optionalString isAppleSilicon "/opt/homebrew/bin";
    cleanup = "uninstall";
    taps = [
      "homebrew/cask"
      "homebrew/cask-drivers"
    ] ++ lib.optionals isAppleSilicon ["simnalamburt/x"];
    brews = [
    ] ++ lib.optionals isAppleSilicon ["simnalamburt/x/podman-apple-silicon"];
    casks = [
      "brave-browser"
      "slack"
      "rectangle"
      "alt-tab"
      "icanhazshortcut"
      "whatsapp"
      "zoom"
      "discord"
      "logitech-options"
    ] ++ lib.optionals (!isAppleSilicon) ["docker"];
  };

  environment.etc = {
    "per-user/.gitconfig".text = ''
      [user]
        name = Matthew Murray
        email = mattmurr.uk@gmail.com
        signingkey = C887ABBA2A2B1837A1DF243D3B11FE4ADE028D64
      [commit]
        gpgsign = true
    '';
  };

  system.activationScripts.extraUserActivation.text = ''
    ln -sfn /etc/per-user/.gitconfig ~/
  '';

  environment.variables = {
    EDITOR = "nvim";
    AWS_VAULT_BACKEND = "pass";
    AWS_VAULT_PASS_PREFIX = "aws-vault";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    enableSyntaxHighlighting = true;
    loginShellInit = lib.optionalString isAppleSilicon ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';
    interactiveShellInit = ''
      alias ls='ls -G'
      alias ll='ls -l -G'

      plugins+=tmux
      ZSH_TMUX_AUTOSTART=true
      
      plugins=(git direnv)

      plugins+=vi-mode
      VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
      VI_MODE_SET_CURSOR=true

      plugins+=fzf
      FZF_BASE=${pkgs.fzf.out}/share/fzf
      export FZF_DEFAULT_COMMAND="fd -t f --hidden --follow --exclude '.git' --ignore-file $HOME/.gitignore --color=always"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_ALT_C_COMMAND="fd -t d --hidden --follow --exclude '.git' --ignore-file $HOME/.gitignore --color=always"
      export FZF_DEFAULT_OPTS="--height 100% --layout=reverse --border --ansi"
      export FZF_CTRL_T_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --style=numbers --color=always --line-range :500 {}'"

      . ${pkgs.oh-my-zsh.out}/share/oh-my-zsh/oh-my-zsh.sh
    '';
  };

  programs.tmux = {
    enable = true;
    extraConfig = ''
      # Vi mode
      set-window-option -g mode-keys vi
      # Escape key is instant
      set -s escape-time 0
      # increase scrollback buffer size
      set -g history-limit 50000
      # tmux messages are displayed for 4 seconds
      set -g display-time 4000
      # refresh 'status-left' and 'status-right' more often
      set -g status-interval 5
      # focus events enabled for terminals that support them
      set -g focus-events on
      # super useful when using "grouped sessions" and multi-monitor setup
      setw -g aggressive-resize on
      set -g set-titles on
      set -g set-titles-string "#T"
      set-option -g automatic-rename on
      set-option -sa terminal-overrides ',XXX:RGB'
      set -g status-fg colour248
      set -g status-bg colour236
      set -g window-status-format "#[fg=colour248] #I #W "
      set -g window-status-current-format "#[fg=colour255,noreverse,bg=colour241] #I #W "
      set -g status-right "%a %d %b %I:%M:%S%p"
      set -g status-right-length 300
      set -g mouse on
      set-option -s set-clipboard off
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel \
      "pbcopy"
      bind-key -T root WheelUpPane select-pane -t =\; copy-mode -e\; send-keys -M
      # Double LMB Select & Copy (Word)
      bind-key -T copy-mode-vi DoubleClick1Pane \
      select-pane \; \
      send-keys -X select-word \; \
      send-keys -X copy-pipe-no-clear "pbcopy"
      bind-key -n DoubleClick1Pane \
      select-pane \; \
      copy-mode -M \; \
      send-keys -X select-word \; \
      send-keys -X copy-pipe-no-clear "pbcopy"
      # Triple LMB Select & Copy (Line)
      bind-key -T copy-mode-vi TripleClick1Pane \
      select-pane \; \
      send-keys -X select-line \; \
      send-keys -X copy-pipe-no-clear "pbcopy"
      bind-key -n TripleClick1Pane \
      select-pane \; \
      copy-mode -M \; \
      send-keys -X select-line \; \
      send-keys -X copy-pipe-no-clear "pbcopy"
      bind-key -T copy-mode-vi Escape send -X clear-selection
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      bind-key -T copy-mode-vi 'y' send -X copy-selection-and-cancel
      bind k kill-session
      # Always open using current working directory
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      # Navigation between splits
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind-key m choose-window "join-pane -s '%%'"
      # Reset layout and pane sizes
      bind = select-layout tiled
    '';
  };

  services.lorri.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
