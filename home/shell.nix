{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''autoload -U compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"'';
    envExtra = ''
      # Home-manager profile PATH for standalone hm (mini uses this setup).
      # Set in .zshenv so non-interactive SSH commands (ssh mini "git status")
      # can find home-manager tools like git-crypt.
      export PATH="$HOME/.nix-profile/bin:$HOME/.local/state/nix/profiles/home-manager/home-path/bin:$PATH"
    '';
    initContent = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      [[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:$PATH"
      export CARGO_HOME="$XDG_DATA_HOME"/cargo
      export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
      export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
      export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
      export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
      export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
      export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
      export AZURE_CONFIG_DIR="$XDG_DATA_HOME"/azure
      export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
      export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
      export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
      alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
      alias conda=mamba
      cursor() { open -a "/Applications/Cursor.app" "$@" ; }
      if [[ "$OSTYPE" == "darwin"* ]]; then
        ulimit -n 16384
      fi
      nb2script() { jupyter nbconvert --to script --no-prompt "$1"; }
      # scrape site for offline docs https://superuser.com/a/42428
      # wget -m -p -E -k -np www.example.com/documentation/
      sshL() { ssh -L 6000:"$1":22 server_name; }
      # Fix completions for uv run.
      _uv_run_mod() {
        if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
            _arguments '*:filename:_files'
        else
            _uv "$@"
        fi
      }
      compdef _uv_run_mod uv
      [[ -f ~/.local/bin/worktree-claude ]] && eval "$(~/.local/bin/worktree-claude --completions)"
      # Fix for zsh-autocomplete: NixOS default config overrides arrow key bindings
      # # Set up key array for portability across terminals
      # typeset -g -A key
      # key[Up]="''${terminfo[kcuu1]}"
      # key[Down]="''${terminfo[kcud1]}"
      # [[ -n "''${key[Up]}" ]] && bindkey "''${key[Up]}" up-line-or-search
      # [[ -n "''${key[Down]}" ]] && bindkey "''${key[Down]}" down-line-or-search
    '';
    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.dataHome}/zsh/zsh_history";
    plugins = [
      {
        # Must be before plugins that wrap widgets, such as zsh-autosuggestions or fast-syntax-highlighting
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
      # zsh-autosuggestions is disabled because zsh-autocomplete provides similar functionality
      # {
      #   name = "zsh-autosuggestions";
      #   file = "zsh-autosuggestions.zsh";
      #   src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      # }
      # Temporarily disabled to debug tab-closing issue
      # {
      #   # zsh-autocomplete should be loaded after syntax highlighting plugins
      #   name = pkgs.zsh-autocomplete.pname;
      #   src = pkgs.zsh-autocomplete.src;
      # }
      {
        name = "zsh-histdb";
        src = pkgs.fetchFromGitHub {
          owner = "larkery";
          repo = "zsh-histdb";
          rev = "30797f0c50c31c8d8de32386970c5d480e5ab35d";
          hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
        };
      }
      {
        name = "zsh-histdb-skim";
        src = pkgs.fetchFromGitHub {
          owner = "m42e";
          repo = "zsh-histdb-skim";
          rev = "3af19b6ec38b93c85bb82a80a69bec8b0e050cc5";
          hash = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
        };
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };

  home.shellAliases = {
    lg = "lazygit";
    lzd = "lazydocker";
    config = "git --git-dir=$HOME/.cfg/ --work-tree=$HOME";
    chrome = "open -a 'Google Chrome'";
    rcp = "rsync -ah --info=progress2";
    rsync2 = "rsync -chavzP --stats";
    # upload() { rsync -rlptzv --progress --delete --exclude=.git --filter=":- .gitignore" . het:/root/repos/${PWD##*/} }
    # rsync -rlptzv --progress --delete --filter='+ **/*.env' --filter=':- .gitignore' . het:/root/repos/nix-config
  };
}
