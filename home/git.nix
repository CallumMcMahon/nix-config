{
  lib,
  username,
  useremail,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f ~/.gitconfig
  '';

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = username;
    userEmail = useremail;

    # includes = [
    #   {
    #     # use diffrent email & name for work
    #     path = "~/work/.gitconfig";
    #     condition = "gitdir:~/work/";
    #   }
    # ];

    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "vim";
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      remote.origin.prune = true;
      url."git@github.com:".insteadOf = "git@personal:";
      pull.rebase = false;
    };

    difftastic = {
      enable = true;
      background = "dark";
      # display = "side-by-side";
    };

    delta = {
      enable = false;
      options = {
        features = "side-by-side";
      };
    };

    aliases = {
      # common aliases
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m";
      ca = "commit -am";
      dc = "diff --cached";
      amend = "commit --amend -m";

      # difftastic aliases
      dft = "diff";
      dlog = "log -p --ext-diff";
      dshow = "show --ext-diff";

      # aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };

    ignores = ["*.swp" ".idea" ".vscode" "research/" "lightning_logs/" ".mlflow" "outputs/" ".DS_Store" ".direnv/" ".envrc"];
  };
}
