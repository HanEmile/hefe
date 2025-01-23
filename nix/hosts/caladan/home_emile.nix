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
          nix-mode # Nix
          magit # Git
          parinfer-rust-mode # Lisp Parens
          tuareg # OCaml
          howm # Notes
        ];
      extraConfig = ''
        (require 'package)
        (package-initialize)
        (add-to-list 'package-archives
          '("melpa" . "https://melpa.org/packages/") t)
        (unless package-archive-contents
          (package-refresh-contents))

        (dolist (package '(use-package sly corfu org))
          (unless (package-installed-p package)
            (package-install package)))

        (when (display-graphic-p)
          (tool-bar-mode 0)
          (scroll-bar-mode 'left))

        (load-theme 'leuven) ;; light theme
        (setq pixel-scroll-precision-mode 1)

        (setq standard-indent 2)
        (setq create-lockfiles nil)
        (setq delete-old-versions -1)
        (setq make-backup-files nil) ; stop creating ~ files
        (setq version-control t)
        (setq coding-system-for-write 'utf-8)
        (setq-default indent-tabs-mode nil) ;; use spaces, not tabs
        (setq show-paren-delay 0)
        (show-paren-mode)

        (setq custom-file (expand-file-name "custom.el" user-emacs-directory))

        (add-to-list 'display-buffer-alist
                     '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
                       (display-buffer-no-window)
                       (allow-no-window . t)))

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

        ;; org-mode
        (use-package org)
        (define-key global-map "\C-cl" 'org-store-link)
        (define-key global-map "\C-ca" 'org-agenda)
        (setq org-log-done t)

        ;; =============== plugins ==================

        ;; Corfu - COmpletion in Region FUnction
        ;; https://github.com/minad/corfu
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
                      ("S-<return>" . corfu-insert))
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

        ;; Marginalia - Marginalia in the minibuffer
        ;; https://github.com/minad/marginalia
        (use-package marginalia
          :custom
          (marginalia-max-relative-age 0)
          (marginalia-align 'right)
          :init
          (marginalia-mode))

        ;; == Fancy icons ==
        ;; all-the-icons
        ;; https://github.com/domtronn/all-the-icons.el
        (use-package all-the-icons
          :if (display-graphic-p))

        ;; ... also in completions 
        (use-package all-the-icons-completion
          :after (marginalia all-the-icons)
          :hook (marginalia . all-the-icons-completion-marginalia-setup)
          :init (all-the-icons-completion-mode))

        ;; vectico.el - VERTical Interactive COmpletion
        ;; https://github.com/minad/vertico
        (use-package vertico
          :init (vertico-mode)
          :custom (vertico-count 13)
          (vertico-resize t)
          (vertico-cycle nil)
          :config (vertico-mode))

        ;; orderless - completion
        ;; This allows searching for space separated terms in any order
        ;; https://github.com/oantolin/orderless
        (use-package orderless
          :init (setq completion-styles '(orderless basic)
                      completion-category-defaults nil
                      completion-category-overrides '((file (styles partial-completion)))
                      ))


        ;; markdown mode
        ;; https://jblevins.org/projects/markdown-mode/
        (use-package markdown-mode
          :ensure t
          :mode ("README\\.md\\'" . gfm-mode)
          :init (setq markdown-command "multimarkdown"))

        ;; Minibuffer with help when waiting too long
        ;; In emacs per default with Emacs v30
        (use-package which-key
          :ensure t
          :config
          (setq which-key-idle-delay 0.1)
          (setq which-key-idle-secondary-delay 0.1)
          (which-key-mode))

        ;; imenu-list - Display imenu (symbols) in a separate buffer
        ;; https://github.com/bmag/imenu-list
        (use-package imenu-list :ensure t
          :init
          (setq imenu-list-auto-resize t)
          (setq imenu-list-focus-after-activation t))

        ;; flycheck - Syntax checking for GNU Emacs¶
        ;; https://www.flycheck.org/en/latest/
        (use-package flycheck
          :ensure t
          :init (global-flycheck-mode))

        ;; allow the deletion of selected text (don't know why this isn't implemented by default)
        (use-package delsel
          :ensure nil ; no need to install it as it is built-in, but needs to be activated
          :hook (after-init . delete-selection-mode))

        ; howm mode
        ; (require 'howm)
        (use-package howm
          :ensure t
          :init
          ;; Where to store the files?
          (setq howm-file-name-format "%Y/%m/%Y-%m-%d-%H%M%S.md")
          (setq howm-view-title-header "#") ; markdown mode!
          (setq howm-directory "~/Notes")
          (setq howm-home-directory howm-directory)
          (setq howm-keyword-file (expand-file-name ".howm-keys" howm-home-directory))
          (setq howm-history-file (expand-file-name ".howm-history" howm-home-directory))

          ;; Use ripgrep as grep
          (setq howm-view-use-grep t)
          (setq howm-view-grep-command "rg")
          (setq howm-view-grep-option "-nH --no-heading --color never")
          (setq howm-view-grep-extended-option nil)
          (setq howm-view-grep-fixed-option "-F")
          (setq howm-view-grep-expr-option nil)
          (setq howm-view-grep-file-stdin-option nil))


        ;; Rename buffers to their title
        (add-hook 'howm-mode-hook 'howm-mode-set-buffer-name)
        (add-hook 'after-save-hook 'howm-mode-set-buffer-name)

        ; OCaml mode
        (use-package tuareg)
        (setq tuareg-indent-align-with-first-arg t)

        (defun insert-date ()
          "Insert today's date at point"
          (interactive "*")
          (insert (format-time-string "%F")))
        (global-set-key (kbd "C-c C-.") #'insert-date)


        ;; Configure the Lisp program for SLIME
        (add-to-list 'exec-path "/Users/emile/.nix-profile/bin")
        (defvar inferior-lisp-program "sbcl")

        ;; configure parinfer to be enabled as a mode when the major lisp mode is enabled
        (add-to-list 'load-path "/Users/emile/parinfer-rust")
        (add-hook 'emacs-lisp-mode 'parinfer-rust-mode)
        (add-hook 'emacs-lisp-mods (lambda () (lispy-mode 1)))

        ;; erc (emacs irc) settings
        (use-package erc
            :config
            (setopt erc-modules
                (seq-union '(sals nicks bufbar nickbar scrolltobottom)
                           etc-modules))
            (setopt erc-sasl-mechanism 'external)


            :custom
            (erc-prompt-for-nickserv-password nil)
            (erc-inhibit-multiline-input t)
            (erc-send-whitespace-lines t)
            (erc-ask-about-multiline-input t)
            (erc-server-reconnect-timeout 30)
            (erc-interactive-display 'buffer)

            (erc-autojoin-timing 'ident)
            (erc-autojoin-channels-alist '((Libera.Chat "#r2wars")))

            :bind
            ;; Insert \n when hitting <RET> and send messages using C-c C-c
            (:map erc-mode-map
                  ("RET" . nil)
                  ("C-c C-c" . #'erc-send-current-line)))

        (use-package ultra-scroll
             ; if you git clone'd instead of package-vc-install
             ;:load-path "~/code/emacs/ultra-scroll"

             :init
             (setq scroll-conservatively 101 ; important!
                 scroll-margin 0) 
             :config
                 (ultra-scroll-mode 1))
        
        (global-set-key (kbd "C-c e l") (lambda ()
            (interactive)
            (if (get-buffer "irc.libera.chat")
                (erc-track-switch-buffer 1)
                (when (y-or-n-p "Start ERC? ")
                  (erc-tls :server "irc.libera.chat"
                           :port 6697
                           :nick "hanemile"
                           :client-certificate
                             '(,(expand-file-name "~/libera.key")
                               ,(expand-file-name "~/libera.crt")))))))

        (use-package org-roam
          :ensure t
          :custom
          (org-roam-directory (file-truename "/Users/emile/notes"))
          :bind (("C-c n l" . org-roam-buffer-toggle)
                 ("C-c n f" . org-roam-node-find)
                 ("C-c n g" . org-roam-graph)
                 ("C-c n i" . org-roam-node-insert)
                 ("C-c n c" . org-roam-capture)
                 ;; Dailies
                 ("C-c n j" . org-roam-dailies-capture-today))
          :config

          ;; If you're using a vertical completion framework, you might want a more informative completion interface
          (setq org-roam-node-display-template
            (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
          (org-roam-db-autosync-mode)

          ;; If using org-roam-protocol
          (require 'org-roam-protocol))

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
        # tab_title_template = "{index}[{layout_name[0:2]}]: {title.replace('emile', 'e')}";
        tab_title_template = "{index} {title.replace('emile', 'e')}";

        editor = "/Users/emile/.cargo/bin/hx";

        macos_option_as_alt = "no";
        macos_quit_when_last_window_closed = "yes";

        kitty_mod = "ctrl+shift";

        clear_all_shortcuts = "";

        allow_remote_control = "yes";
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
    bat
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
    unstable.helix

    ## formatter
    nixfmt-rfc-style # official formatter for nix code

    ## language server
    # nodePackages_latest.typescript-language-server # js / typescript
    nil # nix 
    nodePackages.yaml-language-server # yaml
    python312Packages.python-lsp-server # python
    gopls # golang

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
    sbcl
    #clasp-common-lisp
    # clisp

    # infrastructure as code foo
    terraform
    # ansible

    portmidi

    tiny # irc

    rlwrap

    entr

    python312

    z3 # theorem prover
    python312Packages.z3-solver

    openvpn

    ocaml

    taskwarrior3

    drawio

    # blender

    # rustdesk

    # ] ++ lib.optionals stdenv.isDarwin [
  ];
}
