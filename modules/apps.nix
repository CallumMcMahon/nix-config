{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # neovim
    git
    just # use Justfile to simplify nix-darwin's commands
  ];
  environment.variables.EDITOR = "nvim";

  homebrew = {
    enable = false;

    onActivation = {
      autoUpdate = true; # Fetch the newest stable branch of Homebrew's git repo
      upgrade = true; # Upgrade outdated casks, formulae, and App Store apps
      # 'zap': uninstalls all formulae(and related files) not listed in the generated Brewfile
      cleanup = "zap";
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      Xcode = 497799835;
    };

    taps = [
      "homebrew/services"
    ];

    # `brew install`
    brews = [
      "wget" # download tool
      "curl" # no not install curl via nixpkgs, it's not working well on macOS!
      "aria2" # download tool
      "httpie" # http client
    ];

    # `brew install --cask`
    casks = [
      "firefox"
      "google-chrome"
      "visual-studio-code"

      "anki"
      "raycast" # (HotKey: alt/option + space)search, caculate and run scripts(with many plugins)
      "stats"

      # Development
      "insomnia" # REST client
      "wireshark" # network analyzer
    ];
  };
}
