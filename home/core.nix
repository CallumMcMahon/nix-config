{
  pkgs,
  pkgs-unstable,
  config,
  ...
}: let
  stablePackages = with pkgs; [
    sqlite
    wget
    zip
    lazygit
    lazydocker
    ollama
    pqrs
    # rustc
    # cargo
    rustup # either cargo or rustup
    rsync # default macos version is old
    duckdb
    libiconv
    nil
    age
    gnupg
    git-crypt
    libfido2
    docker
    docker-compose
    font-awesome
    fzf
    htop
    jq
    yq
    ripgrep
    tree
    tmux
    unzip
    xz
    p7zip
    aria2
    socat
    nmap
    file
    gawk
    zstd
    alejandra # nix code formatter
    ranger
    joshuto # trying ranger alternative
    nodejs # needed for neovim plugins
    rclone
    restic
  ];
  unstablePackages = with pkgs-unstable; [
    colima # xdg home support?
    micromamba
    mamba-cpp

    neovim
    helix
    zellij
    # claude-code # installed outside nix for faster updates
    gemini-cli
  ];
in {
  home.packages = stablePackages ++ unstablePackages;
  xdg.enable = true; # verify with # nix run github:b3nj5m1n/xdg-ninja

  # Create symlinks manually to avoid nix store copies
  home.activation.linkDotfiles = config.lib.dag.entryAfter ["writeBoundary"] ''
    # Detect repo location dynamically using git or fall back to conventional location
    if command -v git >/dev/null 2>&1; then
      # Try to find the git repo root from common locations
      for search_dir in "${config.home.homeDirectory}/nix-config" "${config.home.homeDirectory}/.config/nix-config" "${config.home.homeDirectory}"; do
        if [ -d "$search_dir/.git" ]; then
          REPO_ROOT="$(cd "$search_dir" && git rev-parse --show-toplevel 2>/dev/null)" || REPO_ROOT=""
          if [ -n "$REPO_ROOT" ] && [ -d "$REPO_ROOT/dotfiles" ]; then
            break
          fi
        fi
      done
      # If not found, try PWD as a last resort
      if [ -z "$REPO_ROOT" ] || [ ! -d "$REPO_ROOT/dotfiles" ]; then
        REPO_ROOT="${config.home.homeDirectory}/nix-config"
      fi
    else
      REPO_ROOT="${config.home.homeDirectory}/nix-config"
    fi

    DOTFILES_DIR="$REPO_ROOT/dotfiles"

    if [ ! -d "$DOTFILES_DIR" ]; then
      echo "Warning: dotfiles directory not found at $DOTFILES_DIR"
      echo "Skipping dotfiles linking"
      exit 0
    fi

    # Create necessary parent directories
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/karabiner"
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/iterm2"
    $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/lazygit"

    # Function to create or update symlink
    link_config() {
      local target="$1"
      local link="$2"
      if [ ! -e "$target" ]; then
        echo "Warning: Source does not exist: $target"
        return
      fi
      if [ -e "$link" ] || [ -L "$link" ]; then
        if [ "$(readlink "$link" 2>/dev/null)" != "$target" ]; then
          $DRY_RUN_CMD rm -rf "$link"
          $DRY_RUN_CMD ln -sf "$target" "$link"
        fi
      else
        $DRY_RUN_CMD ln -sf "$target" "$link"
      fi
    }

    # Create directory symlinks
    link_config "$DOTFILES_DIR/helix" "${config.xdg.configHome}/helix"
    link_config "$DOTFILES_DIR/zellij" "${config.xdg.configHome}/zellij"
    link_config "$DOTFILES_DIR/nvim" "${config.xdg.configHome}/nvim"
    link_config "$DOTFILES_DIR/python" "${config.xdg.configHome}/python"

    # Create file symlinks
    link_config "$DOTFILES_DIR/karabiner/karabiner.json" "${config.xdg.configHome}/karabiner/karabiner.json"
    link_config "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" "${config.xdg.configHome}/iterm2/com.googlecode.iterm2.plist"
    link_config "$DOTFILES_DIR/lazygit/config.yml" "${config.xdg.configHome}/lazygit/config.yml"
  '';

  programs = {
    # modern vim
    neovim = {
      enable = false;
      defaultEditor = true;
      vimAlias = true;
      package = pkgs-unstable.neovim;
      plugins = [pkgs.vimPlugins.lazy-nvim];
      # extraLuaConfig =
      #   # lua
      #   ''
      #     require("lazy").setup({
      #       -- disable all update / install features
      #       -- this is handled by nix
      #       rocks = { enabled = false },
      #       pkg = { enabled = false },
      #       install = { missing = false },
      #       change_detection = { enabled = false },
      #       spec = {
      #         -- TODO
      #       },
      #     })
      #   '';
    };

    vscode = {
      enable = false;
      package = pkgs-unstable.vscode;
      profiles.default.extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
        asvetliakov.vscode-neovim
        dracula-theme.theme-dracula

        ms-toolsai.jupyter
        ms-toolsai.jupyter-keymap

        yzhang.markdown-all-in-one
        waderyan.gitblame
        jnoortheen.nix-ide
        charliermarsh.ruff
        github.copilot
        github.copilot-chat
      ];
    };

    # A modern replacement for 'ls'
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      enableZshIntegration = true;
    };

    # terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          sort_dir_first = true;
        };
      };
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
