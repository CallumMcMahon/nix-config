{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = ''autoload -U compinit && compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"'';
    initContent = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      export CARGO_HOME="$XDG_DATA_HOME"/cargo
      export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
      export NPM_CONFIG_INIT_MODULE="$XDG_CONFIG_HOME"/npm/config/npm-init.js
      export NPM_CONFIG_CACHE="$XDG_CACHE_HOME"/npm
      export NPM_CONFIG_TMP="$XDG_RUNTIME_DIR"/npm
      export PYTHONSTARTUP="$XDG_CONFIG_HOME"/python/pythonrc
      export AZURE_CONFIG_DIR="$XDG_DATA_HOME"/azure
      export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
      export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
      export PSQL_HISTORY="$XDG_STATE_HOME/psql_history"
      export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
      alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
      alias conda=mamba
      cursor() { open -a "/Applications/Cursor.app" "$@" ; }
      nb2script() { jupyter nbconvert --to script --no-prompt "$1"; }
      # scrape site for offline docs https://superuser.com/a/42428
      # wget -m -p -E -k -np www.example.com/documentation/
      sshL() { ssh -L 6000:"$1":22 cam45819@ushpc-login2.gsk.com; }
      upload() { rsync -rlptzv --progress --delete --exclude=.git --filter=":- .gitignore" . het:/root/repos/${PWD##*/} }
    '';
    dotDir = ".config/zsh";
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
      {
        name = "zsh-autosuggestions";
        file = "zsh-autosuggestions.zsh";
        src = "${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions";
      }
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
  };
}
