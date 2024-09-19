final: prev: {
  vokobe = final.callPackage ./vokobe { inherit (final) naersk; };
  r2wars-web = final.callPackage ./r2wars-web { };
}
