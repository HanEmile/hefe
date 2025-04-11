{ vimUtils, fetchgit, ... }:

let
  build-vim = vimUtils.buildVimPluginFrom2Nix;

  build = ({name, owner, rev, sha256}: build-vim {
    name = name;
    src = fetchgit {
      url = "https://github.com/${owner}/${name}";
      rev = rev;
      sha256 = sha256;
    };
    dependencies = [];
  });
in {
  lisp = {
    vlime = build {
      name = "vlime";
      owner = "l04m33";
      rev = "065b95f3ac7a455314c2bdefeb2b792f290034df";
      sha256 = "1bmmskdwvbl6lvbnjp9lls86rz0vzmk73y644bjb9ix9ygmjbia4";
    };
  };
}
