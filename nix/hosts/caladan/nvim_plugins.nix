{ vimUtils, fetchgit, ... }:

let
  build = ({name, owner, rev, sha256}: vimUtils.buildVimPlugin {
    inherit name;
    src = fetchgit {
      inherit rev sha256;
      url = "https://github.com/${owner}/${name}";
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
