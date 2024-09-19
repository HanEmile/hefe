{ pkgs, ... }:

{
  home = {
    # The state version is required and should stay at the version you
    # originally installed.
    stateVersion = "22.11";
    username = "emile";
    homeDirectory = "/Users/emile";
  };

  programs = {

    # let home-manager install and manage itself
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
      # autosuggestions.enable = true;
      # enableAutosuggestions = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "git"
          "web-search"
          "urltools"
        ];
      };

      defaultKeymap = "viins";

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

    emacs = {
      enable = true;
      package = pkgs.emacs;
      extraPackages =
        epkgs: with epkgs; [
          nix-mode
          magit
          meow
        ];
      extraConfig = ''
        (setq standard-indent 2)

        ;; MELPA Packages
        (require 'package)
        (package-initialize)
        (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
        (unless package-archive-contents
          (package-refresh-contents))

        ;; Install packages.
        (dolist (package '(use-package sly corfu org))
          (unless (package-installed-p package)
            (package-install package)))

        (use-package org)

        ;(use-package evil-colemak-basics)

        (when (display-graphic-p)
          (tool-bar-mode 0)
          (scroll-bar-mode 0))
        (setq inhibit-startup-screen t)

        (load-theme 'leuven) ;; light theme

        ;; pixel perfect scrolling
        (setq pixel-scroll-precision-mode 1)

        ;; dont create lockfiles
        (setq create-lockfiles nil)

        ;; delete excess backup version silently
        (setq delete-old-versions -1)
        (setq make-backup-files nil) ; stop creating ~ files

        ;; use version controll
        (setq version-control t)

        ;; utf8 by default(setq coding-system-for-read 'utf-8)
        (setq coding-system-for-write 'utf-8)

        ;; org-mode
        (require 'org)
        (define-key global-map "\C-cl" 'org-store-link)
        (define-key global-map "\C-ca" 'org-agenda)
        (setq org-log-done t)

        ;; random emacs foo
        (setq-default indent-tabs-mode nil) ;; use spaces, not tabs
        (setq show-paren-delay 0)
        (show-paren-mode)

        ;; write customizations to a custom file
        (setq custom-file (expand-file-name "custom.el" user-emacs-directory))

        ;; Configure SBCL as the Lisp program for SLIME
        (add-to-list 'exec-path "/Users/emile/.nix-profile/bin")
        (defvar inerior-lisp-program "clisp")

        ;; configure parinfer to be enabled as a mode when the major lisp mode is enabled
        (add-to-list 'load-path "/Users/emile/parinfer-rust")
        (add-hook 'emacs-lisp-mode 'parinfer-rust-mode)
        (add-hook 'emacs-lisp-mods (lambda () (lispy-mode 1)))

        (require 'meow)

        (defun meow-setup ()
          "My colemak-dh meow keybindings with some helix influence."
          (setq meow-cheatsheet-layout meow-cheatsheet-layout-colemak-dh)
          (meow-motion-overwrite-define-key
           ;; Use e to move up, n to move down.
           ;; Since special modes usually use n to move down, we only overwrite e here.
           '("e" . meow-prev)
           '("<escape>" . ignore))
          (meow-leader-define-key
           '("?" . meow-cheatsheet)
           ;; To execute the originally e in MOTION state, use SPC e.
           '("e" . "H-e")
           '("1" . meow-digit-argument)
           '("2" . meow-digit-argument)
           '("3" . meow-digit-argument)
           '("4" . meow-digit-argument)
           '("5" . meow-digit-argument)
           '("6" . meow-digit-argument)
           '("7" . meow-digit-argument)
           '("8" . meow-digit-argument)
           '("9" . meow-digit-argument)
           '("0" . meow-digit-argument))
          (meow-normal-define-key
           '("0" . meow-expand-0)
           '("1" . meow-expand-1)
           '("2" . meow-expand-2)
           '("3" . meow-expand-3)
           '("4" . meow-expand-4)
           '("5" . meow-expand-5)
           '("6" . meow-expand-6)
           '("7" . meow-expand-7)
           '("8" . meow-expand-8)
           '("9" . meow-expand-9)
           '("-" . negative-argument)
           '(";" . meow-reverse)
           '("," . meow-inner-of-thing)
           '("." . meow-bounds-of-thing)
           '("[" . meow-beginning-of-thing)
           '("]" . meow-end-of-thing)
           '("/" . meow-visit)
           '("a" . meow-append)
           '("A" . meow-open-below)
           '("b" . meow-back-word)
           '("B" . meow-back-symbol)
           '("c" . meow-change)
           ; '("C" . )
           '("d" . meow-delete)
           ;'("D" . delete-window)
           '("e" . meow-next)
           '("E" . meow-next-expand)
           '("f" . find-file)
           '("F" . flycheck-list-errors)
           '("g" . meow-cancel-selection)
           '("G" . meow-grab)
           '("h" . meow-mark-word)
           '("H" . meow-mark-symbol)
           '("i" . meow-prev)
           '("I" . meow-prev-expand)
           '("j" . meow-join)
           ; '("J" . )
           '("k" . meow-kill)
           '("K" . meow-paren-mode)
           '("l" . meow-line)
           '("L" . meow-goto-line)
           '("m" . meow-block)
           '("M" . meow-to-block)
           '("n" . meow-left)
           '("N" . meow-left-expand)
           '("o" . meow-right)
           '("O" . meow-right-expand)
           '("p" . meow-yank)
           ; '("P" . )
           '("q" . meow-quit)
           ; '("Q" . )
           '("r" . meow-replace)
           '("R" . undo-redo)
           '("s" . meow-insert)
           '("S" . meow-open-above)
           '("t" . meow-till)
           ; '("T" . )
           '("u" . meow-undo)
           '("U" . meow-undo-in-selection)
           '("v" . meow-search)
           '("w" . meow-next-word)
           '("W" . meow-next-symbol)
           '("x" . meow-delete)
           '("X" . meow-backward-delete)
           '("y" . meow-save)
           '("z" . meow-pop-selection)
           ; '("Z" . )
           '("'" . repeat)
           '("<escape>" . ignore)))


        (meow-setup)
        (meow-global-mode 1)

        ;; Corfu completion
        (use-package corfu
          :custom
          (corfu-cycle-tab t)
          (corfu-auto t)
          (corfu-auto-prefix 2)
          (corfu-auto-delay 0.0)
          (corfu-quit-at-boundary 'separator)
          (corfu-echo-documentation 0.5)
          (corfu-preview-current 'insert)
          (corfu-preselect 'prompt)
          :bind (:map corfu-map
                      ("M-SPC" . corfu-insert-separator)
                      ("RET" . nil)
                      ("TAB" . corfu-next)
                      ([tab] . corfu-next)
                      ("S-TAB" . corfu-previous)
                      ([backtab] . corfu-previous)
                      ("S-<return>" . corfu-inser))
          :init
          (global-corfu-mode)
          (corfu-history-mode)

          :config
          (add-hook 'eshell-mode-hook
                    (lambda ()
                      (setq-local corfu-quit-at-boundary t
                                  corfu-quit-no-match t
                                  corfu-auto nil)
                      (corfu-mode))))

        ;; In-margin annotations
        (use-package marginalia
          :custom
          (marginalia-max-relative-age 0)
          (marginalia-align 'right)
          :init
          (marginalia-mode))

        ;; Fancy icons
        (use-package all-the-icons-completion
          :after (marginalia all-the-icons)
          :hook (marginalia . all-the-icons-completion-marginalia-setup)
          :init (all-the-icons-completion-mode))

        ;; Usable minibuffers
        (use-package vertico
          :init (vertico-mode)
          :custom (vertico-count 13)
          (vertico-resize t)
          (vertico-cycle nil)
          :config (vertico-mode))

        ;; orderless completion
        ;; This allows searching for space separated terms in any order
        (use-package orderless
          :init (setq completion-styles '(orderless basic)
                      completion-category-defaults nil
                      completion-category-overrides '((file (styles partial-completion)))
                      ))

        ;; general purpose emacs settings
        (use-package emacs
          :init

          ;; do not allow cursor in the minibuffer prompt
          (setq minibuffer-prompt-properties
                '(read-only t cursor-intangible t face minibuffer-prompt))
          (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

          ;; support opening new minibuffers from inside existing minibuffers
          (setq enable-recursive-minibuffers t)

          ;; Emacs 28 and newer: Hide commands in M-x which do not work in the current
          ;; mode. Vertico commands are hidden in normal buffers. This setting is
          ;; useful beyond Vertico.
          (setq read-extended-command-predicate #'command-completion-default-include-p))

        ;; Add "lisp" to the list of languages babel is allowed to eval
        ;(setq-default org-babel-lisp-eval-fn #'sly-eval)
        (org-babel-do-load-languages
         'org-babel-load-languages
         '((lisp . t)))

        ;; markdown mode
        (use-package markdown-mode
          :ensure t
          :mode ("README\\.md\\'" . gfm-mode)
          :init (setq markdown-command "multimarkdown"))

        ;; minibuffer with help when waiting too long
        (use-package which-key
          :ensure t
          :config
          (setq which-key-idle-delay 0.1)
          (setq which-key-idle-secondary-delay 0.1)
          (which-key-mode))

        ;; Display imenu (symbols) in a separate buffer
        (use-package imenu-list :ensure t
          :init
          (setq imenu-list-auto-resize t)
          (setq imenu-list-focus-after-activation t))

        ;; error checking
        (use-package flycheck
          :ensure t
          :init (global-flycheck-mode))

        (provide '.emacs)                       ; makes flycheck happy
      '';
    };

    kitty = {
      enable = true;

      # package = pkgs.kitty;

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

        # "cmd+shift+m" = "detach_window ask";

        "command+j" = "kitten pass_keys.py neighboring_window bottom command+j";
        "command+k" = "kitten pass_keys.py neighboring_window top    command+k";
        "command+h" = "kitten pass_keys.py neighboring_window left   command+h";
        "command+l" = "kitten pass_keys.py neighboring_window right  command+l";
        "command+b" = "combine : clear_terminal scroll active : send_text normal,application \x0c";

        # "ctrl+n" = "send_text all \x0e";
        # "ctrl+e" = "send_text all \x01h";
        # "ctrl+n" = "send_text all \x01i";
        # "ctrlshift++n" = "send_text all \x01i";

        # "ctrl+left" = "resize_window wider";
        # "ctrl+right" = "resize_window narrower";
        # "ctrl+up" = "resize_window shorter";
        # "ctrl+down" = "resize_window taller";
      };

      environment = { };
    };
  };

  home.packages = with pkgs; [
    coreutils
    mpv

    # terminal foo
    # kitty
    jq
    ripgrep
    fd
    eza
    lsd
    tree
    broot
    du-dust
    mktemp
    htop
    rsync
    p7zip
    imagemagick
    binwalk
    lftp
    graphviz

    git
    tig

    # nix related tools
    deploy-rs
    cachix
    nixos-rebuild

    # editor
    helix
    nodePackages_latest.typescript-language-server # js language server
    nil # nix language server
    nixfmt-rfc-style # official formatter for nix code
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
    go
    delve

    # c foo
    cmake
    pkg-config

    # iot hack foo
    minicom

    SDL2

    # macos foo
    # karabiner-elements

    # qemu tooling
    qemu
    sphinx # docs
    virt-manager

    # lisp foo
    #unstable.sbcl
    # sbcl
    #clasp-common-lisp
    clisp

    # infrastructure as code foo
    terraform
    ansible

    portmidi

    tiny # irc

    rlwrap

    entr

    # blender

    # ] ++ lib.optionals stdenv.isDarwin [
  ];
}
