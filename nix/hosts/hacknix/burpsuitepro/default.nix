{ pkgs, nixpkgs, ... }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "burpsuitepro";
  version = "2023.3.2";

  src = builtins.fetchurl {
    name = "burpsuite.jar";
    url = "https://portswigger-cdn.net/burp/releases/download?product=pro&version=2023.5.4&type=Jar";
    sha256 = "sha256:1zlcrs3xg5z5kbdnfszrk8bsw0h4hlpfmbf7j0qb6hzncsp8j5p0";
  };

  dontUnpack = true;
  dontBuild = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    echo '#!${pkgs.runtimeShell}
    eval "$(${pkgs.unzip}/bin/unzip -p ${src} chromium.properties)"
    mkdir -p "$HOME/.BurpSuite/burpbrowser/$linux64"
    ln -sf "${pkgs.chromium}/bin/chromium" "$HOME/.BurpSuite/burpbrowser/$linux64/chrome"
    exec ${pkgs.jdk19}/bin/java -jar ${src} "$@"' > $out/bin/burpsuitepro
    chmod +x $out/bin/${pname}
    runHook postInstall
  '';


  preferLocalBuild = true;

  meta = with nixpkgs.lib; {
    description = "An integrated platform for performing security testing of web applications";
    longDescription = ''
      Burp Suite is an integrated platform for performing security testing of web applications.
      Its various tools work seamlessly together to support the entire testing process, from
      initial mapping and analysis of an application's attack surface, through to finding and
      exploiting security vulnerabilities.
    '';
    homepage = "https://portswigger.net/burp/";
    downloadPage = "https://portswigger.net/burp/freedownload";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    #license = licenses.unfree;
    platforms = pkgs.jdk19.meta.platforms;
    hydraPlatforms = [];
    maintainers = with maintainers; [ hanemile ];
  };
}
