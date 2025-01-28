{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    dotDir = ".config/zsh";
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
    ];
  };

  home.shellAliases = {
    lg = "lazygit";
    lzd = "lazydocker";
  };
}
