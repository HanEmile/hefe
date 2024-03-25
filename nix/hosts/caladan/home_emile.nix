{ pkgs, lib, ... }:

{
  home = {
    stateVersion = "22.11";
    username = "emile";
    homeDirectory = "/Users/emile";
  };

  # let home-manager install and manage itself
  programs = {
    home-manager.enable = true;

    direnv = { 
      enable = true;
      nix-direnv.enable = true;
    };

    htop = {
      enable = true;
      settings.show_program_with_path = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      #syntaxHighlighting.enable = true;
      shellAliases = import ./aliases.nix;
      enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "vi-mode" "web-search" "urltools" ];
      };

      # this has to be added, so we can ssh into the host using deploy-rs and
      # access the `nix-store` stuff
      envExtra = ''
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
      '';

      initExtraBeforeCompInit = ''
        ${builtins.readFile ./session_variables.zsh}
        ${builtins.readFile ./functions.zsh}

        eval "$(direnv hook zsh)"

        setopt autocd 		# cd without needing to use the cd command
      '';
    };

    kitty = {
      enable = true;

      # font = pkgs.iosevka;

      font = {
        name = "Iosevka Nerd Font";
        size = 13;
      };

      settings = {
        font_size = 12;

        disable_ligatures = "never";
        close_on_child_death = "yes";

        tab_bar_edge = "top";
        tab_bar_style = "slant";
        tab_bar_min_tabs = 1;

        # tab_title_template = "{index}[{layout_name[0:2]}]: {title.replace('emile', 'e')[title.rfind('/')+1:]}";
        tab_title_template = "{index}[{layout_name[0:2]}]: {title.replace('emile', 'e')}";

        editor = "/Users/emile/.cargo/bin/hx";

        macos_option_as_alt = "no";
        macos_quit_when_last_window_closed = "yes";

        kitty_mod = "ctrl+shift";

        clear_all_shortcuts = "";
      };

      keybindings = {
        "cmd+enter" = "launch --cwd=current --location=split";
        "cmd+shift+enter" = "launch --cwd=current --location=hsplit";

        "cmd+shift+h" = "move_window left";
        "cmd+shift+j" = "move_window down";
        "cmd+shift+k" = "move_window up";
        "cmd+shift+l" = "move_window right";

        "cmd+shift+m" = "detach_window ask";

        "command+j" = "kitten pass_keys.py neighboring_window bottom command+j";
        "command+k" = "kitten pass_keys.py neighboring_window top    command+k";
        "command+h" = "kitten pass_keys.py neighboring_window left   command+h";
        "command+l" = "kitten pass_keys.py neighboring_window right  command+l";
        "command+b" = "combine : clear_terminal scroll active : send_text normal,application \x0c";

        # "ctrl+n" = "send_text all \x0e";
        "ctrl+e" = "send_text all \x01h";
        "ctrl+n" = "send_text all \x01i";
        "ctrlshift++n" = "send_text all \x01i";

        "ctrl+left" = "resize_window wider";
        "ctrl+right" = "resize_window narrower";
        "ctrl+up" = "resize_window shorter";
        "ctrl+down" = "resize_window taller";
      };

      environment = { };
    };
  };

  home.packages = with pkgs; [
    coreutils mpv

    # terminal foo
    kitty
    jq ripgrep fd eza lsd tree broot
    du-dust mktemp htop rsync
    p7zip imagemagick binwalk lftp
    graphviz

    git tig 

    # nix related tools
    deploy-rs
    cachix
    nixos-rebuild

    # editor
    helix
    nodePackages_latest.typescript-language-server # js language server
    nil # nix language server
    nodePackages.yaml-language-server # yaml language server

    # binary foo
    radare2

    # network foo
    curl
    wireguard-tools
    # tailscale

    # rss foo
    yarr

    # go foo
    go delve

    # c foo
    cmake

    # iot hack foo
    minicom

    SDL2

    # macos foo
    # karabiner-elements

    # qemu tooling
    qemu
    sphinx #docs
    virt-manager

    # lisp foo
    sbcl

    # infrastructure as code foo
    terraform ansible

    portmidi

  ] ++ lib.optionals stdenv.isDarwin [
    m-cli
  ];
}
